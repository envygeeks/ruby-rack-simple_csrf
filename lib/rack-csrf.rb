%w(rack-csrf/version securerandom).each { |a| require a }

class String
  def strip_heredoc(offset = 0)
    gsub(/^[ \t]{#{(scan(/^[ \t]*(?=\S)/).min || "").size}}/, offset = "\s" * (offset || 0))
  end
end

module Rack
  class Csrf
    class CSRFSessionUnavailableError < StandardError
      def initialize(msg = nil)
        super msg || "CSRF requires session."
      end
    end

    class CSRFFailedToValidateError < StandardError
      def initialize(msg = nil)
        super msg || "CSRF did not pass."
      end
    end

    def initialize(app, opts = {})
      @field = opts.fetch(:field, "auth")
      @raise = opts.fetch(:raise, false)
      @key = opts.fetch(:key, "csrf")
      @skip = opts.fetch(:skip, [])

      @app = app

      @render_with = opts[:render_with]
      @header = opts.fetch(:header, "HTTP_X_CSRF_TOKEN")
      @methods = %w(POST PUT DELETE PATCH) + opts.fetch(:http_methods, [])
    end

    def continue?(req)
      req.params[@field] == req.env["rack.session"][@key] ||
      req.env[@header] == req.env["rack.session"][@key] ||
      !@methods.include?(req.request_method) ||
      (Array === @skip && @skip.any? do |url|
        meth, path = Regexp.escape(req.request_method), Regexp.escape(req.path)
        url =~ /^#{meth}:#{path}$/ || url =~ /^#{path}$/
      end)
    end

    def raise_if_session_unavailable_for!(req)
      unless req.env["rack.session"]
        raise CSRFSessionUnavailableError
      end
    end

    def setup_csrf_for!(req)
      req.env["rack.session"][@key] ||= SecureRandom.hex(32)
    end

    def render_error_for!(env)
      Proc === @render_with ? @render_with.call(env) : [403, {}, ["Unauthorized"]]
    end

    def call(env, req = Rack::Request.new(env))
      raise_if_session_unavailable_for! req
      setup_csrf_for! req
      return @app.call(env) if continue?(req)
      @raise ? raise(CSRFFailedToValidateError) : render_error_for!(env)
    end

    module Helpers
      extend self

      def csrf_meta_tag(opts = {}, session = session)
        %Q{<meta name="#{opts[:field] || "auth"}" content="#{session[opts[:key] || "csrf"]}">}
      end

      def csrf_form_tag(opts = {}, session = session)
        session_key = session[opts[:key] || "csrf"]
        tag = opts[:tag] || "div"
        <<-HTML.strip_heredoc(opts[:offset])
          <#{tag} class="hidden">
            <input type="hidden" name="#{opts[:field] || "auth"}" value="#{session_key}">
          </#{tag}>
        HTML
      end
    end
  end
end
