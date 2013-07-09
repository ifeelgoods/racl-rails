# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'racl/version'

Gem::Specification.new do |gem|
  gem.name          = "racl"
  gem.version       = Racl::VERSION
  gem.authors       = ["peteygao", "mtparet"]
  gem.email         = ["tech@ifeelgoods.com"]
  gem.description   = "Gem which eases integration of RACL with Rails."
  gem.summary       = "Gem which eases integration of RACL with Rails."
  gem.homepage      = "https://github.com/ifeelgoods/racl-rails"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
