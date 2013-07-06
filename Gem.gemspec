$:.unshift(File.expand_path("../lib", __FILE__))
require "rack-csrf/version"

Gem::Specification.new do |spec|
  spec.homepage = 'https://envygeeks.com/projects/rack-csrf'
  spec.description = 'A simpler CSRF middleware for Rack.'
  spec.email = ['envygeeks@gmail.com']
  spec.version = Rack::Csrf::VERSION
  spec.authors = ['Jordon Bedwell']
  spec.name = 'rack-csrf'
  spec.require_paths = ['lib']
  spec.summary = 'A simpler CSRF middleware for Rack.'
  spec.files = %W(Readme.md Rakefile License Gemfile) + Dir['lib/**/*']

  # --------------------------------------------------------------------------
  # Dependencies.
  # --------------------------------------------------------------------------

  spec.add_development_dependency('rspec', '~> 2.13.0')
  spec.add_development_dependency('rack-test', '~> 0.6.2')
end
