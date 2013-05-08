$:.unshift(File.expand_path('../lib', __FILE__))
require "rack-csrf/version"

Gem::Specification.new do |s|
  s.homepage = "https://envygeeks.com/projects/rack-csrf"
  s.add_development_dependency("guard-rspec", "~> 3.0.0")
  s.description = "A simpler CSRF middleware for Rack."
  s.add_development_dependency("coveralls")
  s.add_development_dependency("rspec")
  s.email = ["envygeeks@gmail.com"]
  s.version = Rack::Csrf::VERSION
  s.authors = ["Jordon Bedwell"]
  s.name = "rack-csrf"
  s.require_paths = ["lib"]
  s.add_development_dependency("rake")
  s.add_development_dependency("simplecov")
  s.add_development_dependency("rack-test")
  s.add_runtime_dependency("rack", "~> 1.5.2")
  s.summary = "A simpler CSRF middleware for Rack."
  s.add_development_dependency("luna-rspec-formatters")
  s.test_files = s.files.grep(%r{^(?:test|spec|features)/})
  s.files = ["Readme.md", "Rakefile", "License", "Gemfile"] + Dir["lib/**/*"]
end
