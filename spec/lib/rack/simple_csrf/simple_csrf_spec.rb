require "rspec/helper"

describe Rack::SimpleCsrf do
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

    @env_skip = {
      "REQUEST_PATH" => "/path/elem",
      "rack.session" => {},
      "PATH_INFO" => "/path/elem",
      "REQUEST_URI" => "/path/elem",
      "REQUEST_METHOD" => "POST",
      "rack.input" => Rack::Lint::InputWrapper.new(StringIO.new)
    }
  end

  it "sends 403 if render_with is not provided and the key is wrong" do
    @env["REQUEST_URI"] = "/?csrf=abc1234"
    @env["QUERY_STRING"] = "csrf=abc1234"
    @env["rack.session"]["csrf"] = "abc123"
    described_class.new(app).call(@env).should eq [403, {}, ["Unauthorized"]]
  end

  it "sends 403 by default without render_with" do
    described_class.new(app).call(@env).should eq [403, {}, ["Unauthorized"]]
  end

  it "accepts the X_CSRF_TOKEN header" do
    @env["rack.session"]["csrf"] = "abc123"
    @env["HTTP_X_CSRF_TOKEN"] = "abc123"
    described_class.new(app).call(@env).should be_true
  end

  it "accepts a normal auth token" do
    @env["REQUEST_URI"] = "/?auth=abc123"
    @env["QUERY_STRING"] = "auth=abc123"
    @env["rack.session"]["csrf"] = "abc123"
    described_class.new(app).call(@env).should be_true
  end

  it "raises if there is no session" do
    @env.delete("rack.session")

    expect_error described_class::CSRFSessionUnavailableError do
      described_class.new(app).call(@env)
    end
  end

  it "creates a new csrf key" do
    @env["rack.session"]["csrf"].should be_nil
    described_class.new(app, :skip => ["/"]).call(@env)
    @env["rack.session"]["csrf"].length.should eq 64
  end

  it "skips anything on the opts skip list" do
    described_class.new(app, :skip => ["POST:/"]).should be_true
    described_class.new(app, :skip => ["/"]).call(@env).should be_a_kind_of(TrueClass)
    described_class.new(app, :skip => []).call(@env).should eq([403, {}, ["Unauthorized"]])
    described_class.new(app, :skip => ["POST:/path/.*"]).call(@env_skip).should be_a_kind_of(TrueClass)
    described_class.new(app, :skip => ["POST:/path"]).call(@env_skip).should eq([403, {}, ["Unauthorized"]])
  end

  it "does not mixup HTTP methods" do
    described_class.new(app, :skip => ["GET:/"]).call(@env).should eq([403, {}, ["Unauthorized"]])
  end

  context "with raise set to true" do
    it "raises if doing a post on a new session" do
      expect_error described_class::CSRFFailedToValidateError do
        described_class.new(app, :raise => true).call(@env)
      end
    end

    it "raises if the csrf key does not match" do
      @env["REQUEST_URI"] = "/?csrf=abc1234"
      @env["QUERY_STRING"] = "csrf=abc1234"
      @env["rack.session"]["csrf"] = "abc123"

      expect_error described_class::CSRFFailedToValidateError do
        described_class.new(app, :raise => true).call(@env)
      end
    end
  end

  context "with raise set to false" do
    context "render_with set with a proc in opts" do
      it "should call the proc" do
        err = [403, {}, ["Abc123"]]
        described_class.new(app, :render_with => Proc.new { |env| err }).call(@env).should eq err
      end
    end
  end
end

describe Rack::SimpleCsrf::Helpers do
  before :each do
    described_class.stub(:session).and_return("csrf" => "abc123")
  end

  describe "#csrf_meta_tag" do
    let(:value) { %Q{<meta name="auth" content="abc123">} }

    it "outputs a meta tag" do
      described_class.csrf_meta_tag.should eq %{<meta name="auth" content="abc123">}
    end

    it "allows a custom field name" do
      described_class.csrf_meta_tag(:field =>
        "my_field").should eq %{<meta name="my_field" content="abc123">}
    end
  end

  describe "#csrf_form_tag" do
    it "should output an input wrapped in a div" do
      described_class.csrf_form_tag.should eq <<-STR.strip_heredoc
        <div class="hidden">
          <input type="hidden" name="auth" value="abc123">
        </div>
      STR
    end

    it "accepts a custom tag" do
      described_class.csrf_form_tag(:tag => "section").should eq <<-STR.strip_heredoc
        <section class="hidden">
          <input type="hidden" name="auth" value="abc123">
        </section>
      STR
    end

    it "accepts a custom field name" do
      described_class.csrf_form_tag(:field => "my_field").should eq <<-STR.strip_heredoc
        <div class="hidden">
          <input type="hidden" name="my_field" value="abc123">
        </div>
      STR
    end
  end
end
