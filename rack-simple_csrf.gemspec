$:.unshift(File.expand_path("../lib", __FILE__))
require "rack/simple_csrf/version"

Gem::Specification.new do |spec|
  spec.files = %W(README.md Rakefile LICENSE Gemfile) + Dir["lib/**/*"]
  spec.homepage = "https://envygeeks.com/projects/rack-csrf"
  spec.description = "A simpler CSRF middleware for Rack."
  spec.summary = "A simpler CSRF middleware for Rack."
  spec.version = Rack::SimpleCsrf::VERSION
  spec.email = ["jordon@envygeeks.io"]
  spec.authors = ["Jordon Bedwell"]
  spec.name = "rack-simple_csrf"
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("rack", "~> 1.5")
  spec.add_development_dependency("envygeeks-coveralls", "~> 1.0")
  spec.add_development_dependency("luna-rspec-formatters", "~> 3.3")
  spec.add_development_dependency("rspec", "~> 3.3")
end
