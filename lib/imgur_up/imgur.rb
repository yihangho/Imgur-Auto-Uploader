require 'rest_client'
require 'json'

module ImgurUp
  class Imgur
    def initialize(client_id, client_secret, refresh_token = nil)
      @client_id     = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
    end

    def pin_request_url
      "https://api.imgur.com/oauth2/authorize?client_id=#{@client_id}&response_type=pin"
    end

    def authorize(pin)
      url = "https://api.imgur.com/oauth2/token"
      response = RestClient.post(url, client_id: @client_id, client_secret: @client_secret, grant_type: "pin", pin: pin)
      output = JSON.parse(response)

      @access_token  = output["access_token"]
      @refresh_token = output["refresh_token"]

      output
    end

    def albums
      url = "https://api.imgur.com/3/account/me/albums"
      response = RestClient.get(url, Authorization: "Bearer #{access_token}")

      JSON.parse(response)["data"]
    end

    def upload(image, album)
      path = "https://api.imgur.com/3/image"

      ::ImgurUp.logger.info "Uploading #{image}"
      response = RestClient.post(path, {image: File.open(image, "rb"), album: album}, Authorization: "Bearer #{access_token}")
      JSON.parse(response)["data"]
    end

    def access_token
      return @access_token if @access_token

      url = "https://api.imgur.com/oauth2/token"
      response = RestClient.post(url, client_id: @client_id, client_secret: @client_secret, grant_type: "refresh_token", refresh_token: @refresh_token)
      @access_token = JSON.parse(response)["access_token"]
    end
  end
end
