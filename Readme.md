# Rack::Csrf

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
  use Rack::Csrf, skip: CSRF_SKIP_LIST, render_with: proc { |*a| denied!(*a) }
end
```

# Options

Defaults: [lib/rack-csrf#L6](https://github.com/envygeeks/rack-csrf/blob/master/lib/rack-csrf.rb#L6)<br />
`Rack::Csrf.header` or `:header` The header key<br />
`Rack::Csrf.key` or `:key` -- The cookie key<br />
`Rack::Csrf.field` or `:field` -- The auth_field token (meta and form)<br />
`Rack::Csrf.raise` or `:raise` -- Raise so it can trickle down to catch `Rack::Csrf::CSRFFailedToValidateError`
<br /><br />
Skip supports an array with values as "METHOD:/url" or "/url".<br /><br />

If you chose not to raise you can optionally set `:render_with` with a callback. The callback will always recieve the `env` for you to call `Rack::Lint` or `Sinatra::Request` yourself. It is done this way so that people who wish to log can log since I don't accept a logger directly, you might also want to do other shit that I don't care about, so rather than giving a shit I might as well just accept a callback and let you do whatever the hell you want.

# Helpers

Default opts: [lib/rack-csrf#L15](https://github.com/envygeeks/rack-csrf/blob/master/lib/rack-csrf.rb#L15)

```ruby
csrf_meta_tag
csrf_form_tag(tag: "div")
```
