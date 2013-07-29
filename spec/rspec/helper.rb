ENV["RACK_ENV"] = "test"

require_relative "../support/simplecov"
require "luna/rspec/formatters/checks"
require "rspec/expect_error"
require "rack-csrf"
require "rack"

Dir[File.expand_path("../../support/**/*.rb", __FILE__)].each do |f|
  require f
end
