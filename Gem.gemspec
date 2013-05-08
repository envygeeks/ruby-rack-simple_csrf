$:.unshift(File.expand_path("../lib", __FILE__))
require "rack-csrf/version"

Gem::Specification.new do |spec|
  spec.homepage = "https://envygeeks.com/projects/rack-csrf"
  spec.add_development_dependency("guard-rspec", "~> 3.0.0")
  spec.description = "A simpler CSRF middleware for Rack."
  spec.add_development_dependency("rack-test")
  spec.add_development_dependency("coveralls")
  spec.add_development_dependency("rspec")
  spec.email = ["envygeeks@gmail.com"]
  spec.version = Rack::Csrf::VERSION
  spec.authors = ["Jordon Bedwell"]
  spec.name = "rack-csrf"
  spec.require_paths = ["lib"]
  spec.add_development_dependency("rake")
  spec.add_development_dependency("simplecov")
  spec.add_runtime_dependency("rack", "~> 1.5.2")
  spec.summary = "A simpler CSRF middleware for Rack."
  spec.add_development_dependency("luna-rspec-formatters")
  spec.files = ["Readme.md", "Rakefile", "License", "Gemfile"] + Dir["lib/**/*"]
end
