ENV["RACK_ENV"] = "test"

require_relative "../support/simplecov"
require "luna/rspec/formatters/checks"
require "rack/simple_csrf"
require "rack"

Dir[File.expand_path("../../support/**/*.rb", __FILE__)].each do |f|
  require f
end
