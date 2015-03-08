require 'rest_client'
require 'json'

module ImgurUp
  class Imgur
    CONFIG_PATH = File.expand_path("~/.imgur-auto-uploader")

    def initialize(logger)
      @logger = logger
    end

    def needs_configuration?
      !config["refresh_token"] || !config["album"] || !config["client_id"] || !config["client_secret"]
    end

    def pin_request_url
      "https://api.imgur.com/oauth2/authorize?client_id=#{config["client_id"]}&response_type=pin"
    end

    def authorize(pin)
      url = "https://api.imgur.com/oauth2/token"
      response = RestClient.post(url, client_id: config["client_id"], client_secret: config["client_secret"], grant_type: "pin", pin: pin)
      output = JSON.parse(response)

      @access_token = output["access_token"]
      config["refresh_token"] = output["refresh_token"]
      write_config
    end

    def albums
      url = "https://api.imgur.com/3/account/me/albums"
      response = RestClient.get(url, Authorization: "Bearer #{access_token}")

      JSON.parse(response)["data"]
    end

    # TODO Remove this! Wrong level of abstration!
    def set_album(album)
      config["album"] = album
      write_config
    end

    def upload(image)
      path = "https://api.imgur.com/3/image"

      logger.info "Uploading #{image}"
      response = RestClient.post(path, {image: File.open(image, "rb"), album: config["album"]}, Authorization: "Bearer #{access_token}")
      JSON.parse(response)["data"]
    end

    def has_refresh_token?
      !!config["refresh_token"]
    end

    def has_album?
      !!config["refresh_token"]
    end

    def config
      return @config if @config

      if File.file?(CONFIG_PATH)
        File.open(CONFIG_PATH) do |f|
          @config = JSON.parse(f.read)
        end
      else
        @config = {}
      end
    end

    def write_config
      File.open(CONFIG_PATH, "w") do |f|
        f << @config.to_json
      end
    end

    private

    def access_token
      return @access_token if @access_token

      url = "https://api.imgur.com/oauth2/token"
      response = RestClient.post(url, client_id: config["client_id"], client_secret: config["client_secret"], grant_type: "refresh_token", refresh_token: config["refresh_token"])

      output = JSON.parse(response)

      @access_token = output["access_token"]
      config["refresh_token"] = output["refresh_token"]
      write_config

      @access_token
    end
  end
end
