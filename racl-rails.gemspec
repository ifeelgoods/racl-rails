# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'racl-rails/version'

Gem::Specification.new do |gem|
  gem.name          = "racl-rails"
  gem.version       = Racl::Rails::VERSION
  gem.authors       = ["peteygao"]
  gem.email         = ["tech@ifeelgoods.com"]
  gem.description   = "The companion gem to RACL (Ruby ACL gem) which eases integration with Rails."
  gem.summary       = "The companion gem to RACL which eases integration with Rails."
  gem.homepage      = "https://github.com/ifeelgoods/racl-rails"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
