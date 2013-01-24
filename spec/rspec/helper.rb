$:.unshift(File.expand_path("../../lib", __FILE__))
ENV["RACK_ENV"] = "test"

unless ENV["COVERAGE"] == false
  require "simplecov"
  SimpleCov.start
end

%w(rack rack-csrf rspec rspec/mocks/standalone pry).each { |a| require a }
