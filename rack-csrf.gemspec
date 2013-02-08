$:.unshift(File.expand_path('../lib', __FILE__))
require "rack-csrf/version"

Gem::Specification.new do |s|
  s.email = ["envygeeks@gmail.com"]
  s.version = Rack::Csrf::VERSION
  s.authors = ["Jordon Bedwell"]
  s.name = "rack-csrf"
  s.require_paths = ["lib"]
  s.add_development_dependency("rake", "~> 10.0.3")
  s.add_runtime_dependency("rack", "~> 1.5.2")
  s.add_development_dependency("rspec", "~> 2.12.0")
  s.summary = "A simpler CSRF middleware for Rack."
  s.description = "A simpler CSRF middleware for Rack."
  s.homepage = "https://envygeeks.com/projects/rack-csrf"
  s.test_files = spec.files.grep(%r{^(?:test|spec|features)/})
  s.files =
    ["Readme.md", "Rakefile", "MIT-License", "Gemfile"] + Dir["lib/**/*"]
end
