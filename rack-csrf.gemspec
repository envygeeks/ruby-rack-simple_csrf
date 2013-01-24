$:.unshift(File.expand_path('../lib', __FILE__))
require "rack-csrf/version"

Gem::Specification.new do |a|
  a.email = ["envygeeks@gmail.com"]
  a.version = Rack::Csrf::VERSION
  a.authors = ["Jordon Bedwell"]
  a.name = "rack-csrf"
  a.require_paths = ["lib"]
  a.add_runtime_dependency("rack")
  a.add_development_dependency("pry")
  a.add_development_dependency("guard")
  a.add_development_dependency("rspec")
  a.add_development_dependency("simplecov")
  a.add_development_dependency("guard-rspec")
  a.summary = "A simpler CSRF middleware for Rack."
  a.description = "A simpler CSRF middleware for Rack."
  a.homepage = "https://envygeeks.com/projects/rack-csrf"
  a.test_files = a.files.grep(%r{^(test|spec|features)/})
  a.files =
    ["Readme.md", "Rakefile", "License.txt", "Gemfile"] + Dir["lib/**/*"]
end
