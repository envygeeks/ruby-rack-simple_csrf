# Rack::Csrf

[![Build Status](https://travis-ci.org/envygeeks/rack-csrf.png?branch=master)](https://travis-ci.org/envygeeks/rack-csrf) [![Coverage Status](https://coveralls.io/repos/envygeeks/rack-csrf/badge.png?branch=master)](https://coveralls.io/r/envygeeks/rack-csrf) [![Code Climate](https://codeclimate.com/github/envygeeks/rack-csrf.png)](https://codeclimate.com/github/envygeeks/rack-csrf)

Rack::Csrf is my personal version of CSRF for Rack.  It implements only a skip list where everything else must be run through the validator.  It does not allow you to be explicit in what you validate, only explicit in what you do not validate.  The goal is to increase security and make you think about what you are doing before you decide to do it.

# Usage

Rack::Csrf has a default output of "Denied", the example belows shows you passing your own caller for us.

```ruby
require "sinatra/base"
require "rack/csrf"
require "logger"

class MyApp < Sinatra::Base
  set(:logger, Logger.new($stdout))

  CSRF_SKIP_LIST = [
    "/my-path",
    "POST:/my-other-path"
  ]

  class << self
    def denied!(exception)
      MyApp.logger.error { exception }
      [403, {}, ["Nice try asshole"]]
    end
  end

  post "/" do
    puts "Hello World"
  end

  helpers Rack::Csrf::Helpers
  use Rack::Csrf, :skip => CSRF_SKIP_LIST, :render_with => proc { |*a| denied!(*a) }
end
```

# Options

`:header` - `HTTP_X_CSRF_TOKEN` The header key<br />
`:key` - `csrf` -- The cookie key<br />
`:field` - `auth`  -- The auth_field token (meta and form)<br />
`:raise` - `false` -- Raise `Rack::Csrf::CSRFFailedToValidateError`
<br /><br />
Skip supports an array with values as "METHOD:/url" or "/url".<br /><br />

If you chose not to raise you can optionally set `:render_with` with a callback. The callback will always recieve the `env` for you to call `Rack::Lint` or `Sinatra::Request` yourself. It is done this way so that people who wish to log can log since I don't accept a logger directly, you might also want to do other shit that I don't care about, so rather than giving a shit I might as well just accept a callback and let you do whatever the hell you want.

# Helpers

```ruby
csrf_meta_tag(:field => "auth")
csrf_form_tag(:tag => "div", :field => "auth")
```
