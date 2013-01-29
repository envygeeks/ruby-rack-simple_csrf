$:.unshift(File.expand_path('../lib', __FILE__))
require "rack-csrf/version"

Gem::Specification.new do |spec|
  spec.email = ["envygeeks@gmail.com"]
  spec.version = Rack::Csrf::VERSION
  spec.authors = ["Jordon Bedwell"]
  spec.name = "rack-csrf"
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency("rack", "~> 1.5.1")
  spec.add_development_dependency("rspec", "~> 2.12.0")
  spec.summary = "A simpler CSRF middleware for Rack."
  spec.description = "A simpler CSRF middleware for Rack."
  spec.homepage = "https://envygeeks.com/projects/rack-csrf"
  spec.test_files = spec.files.grep(%r{^(?:test|spec|features)/})
  spec.files =
    ["Readme.md", "Rakefile", "License.txt", "Gemfile"] + Dir["lib/**/*"]
end
