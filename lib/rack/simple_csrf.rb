require_relative "simple_csrf/version"
require "securerandom"

class String
  def strip_heredoc(offset = 0)
    gsub(/^[ \t]{#{(scan(/^[ \t]*(?=\S)/).min || "").size}}/, offset = "\s" * (offset || 0))
  end
end

module Rack
  class SimpleCsrf
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
      @methods = (%w(POST PUT DELETE PATCH) + opts.fetch(:http_methods, [])).flatten.uniq
    end

    def call(env, req = Rack::Request.new(env))
      raise_if_session_unavailable_for! req
      setup_csrf_for! req
      return @app.call(env) if continue?(req)
      @raise ? raise(CSRFFailedToValidateError) : render_error_for!(env)
    end

    private
    def continue?(req)
      req.params[@field] == req.env["rack.session"][@key] ||
      req.env[@header] == req.env["rack.session"][@key] ||
      ! @methods.include?(req.request_method) || any_skips?(req)
    end

    private
    def any_skips?(req)
      return false if !@skip.is_a? Array || @skip.empty?

      matched_patterns = @skip.select do |pattern|
        method, path = Regexp.escape(req.request_method), Regexp.escape(req.path)
        pattern_split = pattern.split ":"
        if pattern_split.length > 1
          pattern_method = pattern_split[0]
          return false if method !~ /^#{pattern_method}$/
          pattern = pattern_split[1..-1].join ":"
        end
        return true if path =~ /^#{pattern}$/
      end
      return matched_patterns.length > 0
    end

    private
    def raise_if_session_unavailable_for!(req)
      unless req.env["rack.session"]
        raise CSRFSessionUnavailableError
      end
    end

    private
    def setup_csrf_for!(req)
      req.env["rack.session"][@key] ||= SecureRandom.hex(32)
    end

    private
    def render_error_for!(env)
      Proc === @render_with ? @render_with.call(env) : [403, {}, ["Unauthorized"]]
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
