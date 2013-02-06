%w(rack-csrf/version securerandom).each { |a| require a }

module Rack
  class Csrf

    @http_methods = %w(POST PUT DELETE PATCH)
    @header = "HTTP_X_CSRF_TOKEN"
    @raise = false
    @key = "csrf"
    @field = "auth"

    class << self
      attr_accessor :header, :key, :field, :http_methods, :raise

      def parse_helper_opts(opts, session)
        opts[:tag] ||= "section"
        opts[:field] ||= field
        opts[:key] ||= key
        opts[:token] ||= session[opts[:key]]
      opts
      end
    end

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
      @raise = opts.fetch(:raise, self.class.raise)
      @field = opts.fetch(:field, self.class.field)
      @key = opts.fetch(:key, self.class.key)
      @skip = opts.fetch(:skip, [])

      @app = app

      @render_with = opts[:render_with]
      @header = opts.fetch(:header, self.class.header)
      @methods = self.class.http_methods + opts.fetch(:http_methods, [])
    end

    def continue?(req)
      req.params[@field] == req.env["rack.session"][@key] ||
      req.env[@header] == req.env["rack.session"][@key] ||
      !@methods.include?(req.request_method) ||
      @skip.any? { |url| url =~ /^(?:#{req.request_method}:)?#{req.path}$/ }
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
      Proc === @render_with ?
        @render_with.call(env) : [403, {}, ["Unauthorized"]]
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
        opts = Rack::Csrf.parse_helper_opts(opts, session)
        %Q{<meta name="#{opts[:field]}" content="#{opts[:token]}">}
      end

      def csrf_form_tag(opts = {}, session = session)
        opts = Rack::Csrf.parse_helper_opts(opts, session)
        <<-STR.split("\n").map { |s| s.gsub(/^\s+/, "") }.join
          <#{opts[:tag]} class="hidden">
           <input type="hidden" name="#{opts[:field]}" value="#{opts[:token]}">
          </#{opts[:tag]}>
        STR
      end
    end
  end
end
