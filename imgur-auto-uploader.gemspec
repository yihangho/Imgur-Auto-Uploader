$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'imgur_up/version'

Gem::Specification.new do |s|
  s.name    = 'imgur-auto-uploader'
  s.version = ImgurUp::VERSION
  s.license = 'MIT'
  s.author  = 'Yihang Ho'
  s.summary = 'Automatically upload images to Imgur.'

  s.files       = `git ls-files -z`.split("\x0").grep(%r{^(bin|lib)/})
  s.executables = `git ls-files -z`.split("\x0").grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_runtime_dependency 'clipboard', '~> 1.0.6'
  s.add_runtime_dependency 'listen', '~> 2.8.5'
  s.add_runtime_dependency 'mercenary', '~> 0.3.5'
  s.add_runtime_dependency 'rest-client', '~> 1.7.2'
  s.add_runtime_dependency 'terminal-notifier', '~> 1.6.2'
end
