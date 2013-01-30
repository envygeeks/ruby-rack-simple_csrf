# Rack::Csrf

Rack::Csrf is my personal version of CSRF for Rack.  It implements only a skip list where everything else must be run through the validator.  It does not allow you to be explicit in what you validate, only explicit in what you do not validate.  The goal is to increase security and make you think about what you are doing before you decide to do it.
