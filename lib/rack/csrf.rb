require "simple_csrf"
Rack.const_set(:Csrf, Rack::SimpleCsrf)
