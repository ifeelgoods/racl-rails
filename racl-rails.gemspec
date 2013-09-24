$:.push File.expand_path('../lib', __FILE__)

require 'racl/version'

Gem::Specification.new do |gem|
  gem.platform      = Gem::Platform::RUBY
  gem.name          = 'racl-rails'
  gem.version       = Racl::Rails::VERSION
  gem.authors       = ['peteygao', 'mtparet']
  gem.email         = 'tech@ifeelgoods.com'
  gem.description   = 'Simple Gem to use ACL in Rails based on a role given. Great use with Devise.'
  gem.summary       = 'Simple Gem to implement ACL in Rails based on a role given.'
  gem.homepage      = 'https://github.com/ifeelgoods/racl-rails'
  gem.files         = Dir['RELEASENOTES', 'README.md', 'lib/**/*']
  gem.require_path = 'lib'

  spec.add_development_dependency 'rspec', '~> 2.14'
end
