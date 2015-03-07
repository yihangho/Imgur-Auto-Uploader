require 'base64'
require 'rest_client'
require 'json'
require 'clipboard'
require 'terminal-notifier'
require 'listen'

CLIENT_ID     = "3d6d0225e3085ca"
CLIENT_SECRET = "9f0c976c4b4739e9113fcdaba9b11b8c01b215f2"

def imgur_read_saved_data
  path = File.expand_path("~/.imgur-auto-uploader")

  if (File.file?(path))
    File.open(path) do |f|
      JSON.parse(f.read)
    end
  else
    {}
  end
end

def imgur_save_data(key, value)
  saved_data = imgur_read_saved_data
  saved_data[key] = value

  path = File.expand_path("~/.imgur-auto-uploader")
  File.open(path, "w") do |f|
    f << saved_data.to_json
  end
end

def imgur_send_request_pin
  url = "https://api.imgur.com/oauth2/authorize?client_id=#{CLIENT_ID}&response_type=pin"
  puts url
end

def imgur_read_pin
  print "Enter your PIN: "
  gets.strip
end

def imgur_exchange_pin_for_tokens(pin)
  url = "https://api.imgur.com/oauth2/token"
  response = RestClient.post(url, client_id: CLIENT_ID, client_secret: CLIENT_SECRET, grant_type: "pin", pin: pin)
  # p response.headers
  JSON.parse(response)
end

def imgur_exchange_refresh_token_for_tokens(refresh_token)
  url = "https://api.imgur.com/oauth2/token"
  response = RestClient.post(url, client_id: CLIENT_ID, client_secret: CLIENT_SECRET, grant_type: "refresh_token", refresh_token: refresh_token)
  # p response.headers
  JSON.parse(response)
end

def imgur_list_albums(access_token)
  url = "https://api.imgur.com/3/account/me/albums"
  response = RestClient.get(url, Authorization: "Bearer #{access_token}")
  # p response.headers
  JSON.parse(response)["data"]
end

def imgur_prompt_for_album(albums)
  puts "Select album:"
  albums.each_with_index do |album, i|
    puts (i + 1).to_s + ": " + album["title"]
  end
  albums[gets.strip.to_i - 1]["id"]
end

def imgur_upload_image(image_path, access_token, album)
  puts "Uploaded '#{image_path}'"
  path = "https://api.imgur.com/3/image"

  response = RestClient.post(path, {image: File.open(image_path, "rb"), album: album}, Authorization: "Bearer #{access_token}")
  p response.headers
  JSON.parse(response)["data"]
end

def file_base64(path)
  File.open(path) do |f|
    Base64.encode64(f.read)
  end
end

imgur_saved_data = imgur_read_saved_data

if imgur_saved_data["refresh_token"]
  imgur_authorization = imgur_exchange_refresh_token_for_tokens(imgur_saved_data["refresh_token"])
else
  imgur_send_request_pin
  imgur_pin = imgur_read_pin
  imgur_authorization = imgur_exchange_pin_for_tokens(imgur_pin)
end

imgur_save_data("refresh_token", imgur_authorization["refresh_token"])
imgur_access_token = imgur_authorization["access_token"]

if imgur_saved_data["album"]
  imgur_selected_album = imgur_saved_data["album"]
else
  imgur_albums = imgur_list_albums(imgur_access_token)
  imgur_selected_album = imgur_prompt_for_album(imgur_albums)
end

imgur_save_data("album", imgur_selected_album)

exit 0 unless ARGV.length == 1

pid = Process.fork do
  listener = Listen.to(File.expand_path(ARGV[0])) do |_, added, _|
    added.select! { |name| %w(.jpg .png .gif).include?(File.extname(name).downcase) }

    unless added.empty?
      added.map do |path|
        Thread.new(path) do |path|
          imgur_upload_response = imgur_upload_image(path, imgur_access_token, imgur_selected_album)
          puts imgur_upload_response["link"]
          Thread.current[:link] = imgur_upload_response["link"]
        end
      end.each do |thread|
        thread.join

        Clipboard.copy(thread[:link])
        TerminalNotifier.notify("File uploaded, link copied.")
      end
    end
  end
  listener.start
  puts "sleeping"
  sleep
end

Process.detach(pid)
