# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave-mimetype-fu/version'

Gem::Specification.new do |gem|
  gem.name          = "carrierwave-mimetype-fu"
  gem.version       = CarrierWave::MimetypeFu::VERSION
  gem.authors       = ["Kali Donovan"]
  gem.email         = ["kali@deviantech.com"]
  gem.description   = %q{mimetype-fu for carrierwave}
  gem.summary       = %q{Carrierwave extension to set file content type and extension with mimetype-fu}
  gem.homepage      = "https://github.com/deviantech/carrierwave-mimetype-fu"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "mimetype-fu"
  gem.add_runtime_dependency "carrierwave"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rails"
end
