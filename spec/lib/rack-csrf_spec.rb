require "rspec/helper"

describe Rack::Csrf do
  let(:app) { Class.new }
  before :each do
    app.stub(:call).and_return(true)

    @env = {
      "REQUEST_PATH" => "/",
      "rack.session" => {},
      "PATH_INFO" => "/",
      "REQUEST_URI" => "/",
      "REQUEST_METHOD" => "POST",
      "rack.input" => Rack::Lint::InputWrapper.new(StringIO.new)
    }
  end

  it "sends 403 if render_with is not provided and the key is wrong" do
    @env["REQUEST_URI"] = "/?csrf=abc1234"
    @env["QUERY_STRING"] = "csrf=abc1234"
    @env["rack.session"]["csrf"] = "abc123"
    Rack::Csrf.new(app).call(@env).should eq [403, {}, ["Unauthorized"]]
  end

  it "sends 403 by default without render_with" do
    Rack::Csrf.new(app).call(@env).should eq [403, {}, ["Unauthorized"]]
  end

  it "accepts the X_CSRF_TOKEN header" do
    @env["rack.session"]["csrf"] = "abc123"
    @env["HTTP_X_CSRF_TOKEN"] = "abc123"
    Rack::Csrf.new(app).call(@env).should be_true
  end

  it "accepts a normal auth token" do
    @env["REQUEST_URI"] = "/?auth=abc123"
    @env["QUERY_STRING"] = "auth=abc123"
    @env["rack.session"]["csrf"] = "abc123"
    Rack::Csrf.new(app).call(@env).should be_true
  end

  it "raises if there is no session" do
    @env.delete("rack.session")

    expect_error Rack::Csrf::CSRFSessionUnavailableError do
      Rack::Csrf.new(app).call(@env)
    end
  end

  it "creates a new csrf key" do
    @env["rack.session"]["csrf"].should be_nil
    Rack::Csrf.new(app, :skip => ["/"]).call(@env)
    @env["rack.session"]["csrf"].length.should eq 64
  end

  it "skips anything on the opts skip list" do
    Rack::Csrf.new(app, :skip => ["POST:/"]).should be_true
    Rack::Csrf.new(app, :skip => ["/"]).call(@env).should be_true
  end

  it "does not mixup HTTP methods" do
    Rack::Csrf.new(app, :skip => ["GET:/"]).call(@env).should eq([403, {}, ["Unauthorized"]])
  end

  context "with raise set to true" do
    it "raises if doing a post on a new session" do
      expect_error Rack::Csrf::CSRFFailedToValidateError do
        Rack::Csrf.new(app, :raise => true).call(@env)
      end
    end

    it "raises if the csrf key does not match" do
      @env["REQUEST_URI"] = "/?csrf=abc1234"
      @env["QUERY_STRING"] = "csrf=abc1234"
      @env["rack.session"]["csrf"] = "abc123"

      expect_error Rack::Csrf::CSRFFailedToValidateError do
        Rack::Csrf.new(app, :raise => true).call(@env)
      end
    end
  end

  context "with raise set to false" do
    context "render_with set with a proc in opts" do
      it "should call the proc" do
        err = [403, {}, ["Abc123"]]
        Rack::Csrf.new(app, :render_with => Proc.new { |env| err }).call(@env).should eq err
      end
    end
  end
end

describe Rack::Csrf::Helpers do
  before :each do
    Rack::Csrf::Helpers.stub(:session).and_return("csrf" => "abc123")
  end

  describe "#csrf_meta_tag" do
    let(:value) { %Q{<meta name="auth" content="abc123">} }

    it "outputs a meta tag" do
      Rack::Csrf::Helpers.csrf_meta_tag.should eq %{<meta name="auth" content="abc123">}
    end

    it "allows a custom field name" do
      Rack::Csrf::Helpers.csrf_meta_tag(:field =>
        "my_field").should eq %{<meta name="my_field" content="abc123">}
    end
  end

  describe "#csrf_form_tag" do
    it "should output an input wrapped in a div" do
      Rack::Csrf::Helpers.csrf_form_tag.should eq <<-STR.strip_heredoc
        <div class="hidden">
          <input type="hidden" name="auth" value="abc123">
        </div>
      STR
    end

    it "accepts a custom tag" do
      Rack::Csrf::Helpers.csrf_form_tag(:tag => "section").should eq <<-STR.strip_heredoc
        <section class="hidden">
          <input type="hidden" name="auth" value="abc123">
        </section>
      STR
    end

    it "accepts a custom field name" do
      Rack::Csrf::Helpers.csrf_form_tag(:field => "my_field").should eq <<-STR.strip_heredoc
        <div class="hidden">
          <input type="hidden" name="my_field" value="abc123">
        </div>
      STR
    end
  end
end
