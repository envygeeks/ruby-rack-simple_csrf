$:.unshift(File.expand_path("../../lib", __FILE__))
ENV["RACK_ENV"] = "test"

if ENV["SIMPLECOV"] == true
  require "simplecov"
  SimpleCov.start
end

%w(rack rack-csrf rspec rspec/mocks/standalone).each { |file| require file }
