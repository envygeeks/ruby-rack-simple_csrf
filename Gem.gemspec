$:.unshift(File.expand_path("../lib", __FILE__))
require "rack-csrf/version"

Gem::Specification.new do |spec|
  spec.files = %W(Readme.md Rakefile License Gemfile) + Dir["lib/**/*"]
  spec.homepage = "https://envygeeks.com/projects/rack-csrf"
  spec.description = "A simpler CSRF middleware for Rack."
  spec.summary = "A simpler CSRF middleware for Rack."
  spec.email = ["envygeeks@gmail.com"]
  spec.version = Rack::Csrf::VERSION
  spec.authors = ["Jordon Bedwell"]
  spec.name = "rack-csrf"
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("rack", "~> 1.5.2")
  spec.add_development_dependency("rspec", "~> 2.14")
  spec.add_development_dependency("rspec-expect_error", "~> 0")
  spec.add_development_dependency("envygeeks-coveralls", "~> 0")
  spec.add_development_dependency("luna-rspec-formatters", "~> 0")
end
