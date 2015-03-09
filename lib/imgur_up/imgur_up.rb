require 'listen'
require 'clipboard'
require 'terminal-notifier'

module ImgurUp
  class ImgurUp
    def initialize(config_path)
      @config_path = File.expand_path(config_path)
    end

    def needs_configuration?
      %w(client_id client_secret refresh_token album).any? do |key|
        config[key].nil?
      end
    end

    def prompt_for_configuration
      print "Enter your client ID: "
      config["client_id"] = STDIN.gets.strip
      print "Enter your client secret: "
      config["client_secret"] = STDIN.gets.strip

      self.imgur = Imgur.new(config["client_id"], config["client_secret"])

      puts "Log on to the following URL to obtain a PIN."
      puts imgur.pin_request_url
      print "Enter PIN: "
      pin = STDIN.gets.strip
      authorization = imgur.authorize(pin)
      config["refresh_token"] = authorization["refresh_token"]

      puts "Your albums:"
      albums = imgur.albums
      albums.each_with_index do |album, index|
        puts "#{index+1}: #{album["title"]}"
      end
      print "Select the album to upload new files to: "
      album_index = STDIN.gets.to_i - 1
      config["album"] = albums[album_index]["id"]

      save_config
    end

    def watch(directories)
      directories = directories.map { |dir| File.expand_path(dir) }
      directories.each do |dir|
        ::ImgurUp.logger.info "Listening to #{dir}"
      end

      listener = Listen.to(directories, only: /\.(?:jpg|png|gif)$/i) do |_, added, _|
        threads = added.map do |path|
          ::ImgurUp.logger.info "File added: #{path}"

          Thread.new(path) do |path|
            response = imgur.upload(path, config["album"])
            ::ImgurUp.logger.info "Link for #{path}: #{response["link"]}"

            response["link"]
          end
        end

        threads.each do |thread|
          link = thread.value

          Clipboard.copy(link)
          TerminalNotifier.notifiy("File uploaded, link copied.")
        end
      end
      listener.start
    end

    private

    def config
      return @config if @config

      @config =
        if File.file?(@config_path)
          begin
            JSON.load(File.open(@config_path))
          rescue
            {}
          end
        else
          {}
        end
    end

    def save_config
      JSON.dump(config, File.open(@config_path, "w"))
    end

    def imgur
      @imgur ||= Imgur.new(config["client_id"], config["client_secret"], config["refresh_token"])
    end

    attr_writer :imgur
  end
end
