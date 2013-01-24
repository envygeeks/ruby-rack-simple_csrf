# Rack::Csrf

Rack::Csrf is my personal version of CSRF for Rack.  It implements only a skip list where everything else must be run through the validator.  It does not allow you to be explicit in what you validate, only explicit in what you do not validate.
