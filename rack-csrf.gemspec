$:.unshift(File.expand_path('../lib', __FILE__))
require "rack-csrf/version"

Gem::Specification.new do |spec|
  spec.email = ["envygeeks@gmail.com"]
  spec.version = Rack::Csrf::VERSION
  spec.authors = ["Jordon Bedwell"]
  spec.name = "rack-csrf"
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency("rack")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("simplecov")
  spec.summary = "A simpler CSRF middleware for Rack."
  spec.description = "A simpler CSRF middleware for Rack."
  spec.homepage = "https://envygeeks.com/projects/rack-csrf"
  spec.test_files = spec.files.grep(%r{^(?:test|spec|features)/})
  spec.files =
    ["Readme.md", "Rakefile", "License.txt", "Gemfile"] + Dir["lib/**/*"]
end
