require 'imgur_up/imgur'
require 'imgur_up/imgur_up'
require 'imgur_up/version'
require 'logger'

module ImgurUp
  def self.logger
    @logger ||=
      if File.directory?(File.expand_path("~/Library/Logs"))
        Logger.new(File.expand_path("~/Library/Logs/com.yihangho.imgur-auto-uploader.log"))
      elsif File.directory?("/var/log")
        Logger.new("/var/log/com.yihangho.imgur-auto-uploader.log")
      else
        Logger.new(STDOUT)
      end
  end
end
