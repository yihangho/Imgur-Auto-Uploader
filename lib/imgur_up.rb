require 'imgur_up/imgur'
require 'imgur_up/imgur_up'
require 'imgur_up/version'
require 'logger'

module ImgurUp
  def self.logger
    @logger ||= Logger.new(File.expand_path("~/Library/Logs/com.yihangho.imgur-auto-uploader"))
  end
end
