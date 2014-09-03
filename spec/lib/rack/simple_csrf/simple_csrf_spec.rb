require "rspec/helper"

describe Rack::SimpleCsrf do
  let(:app) { Class.new }
  before :each do
    allow(app).to receive(:call).and_return(true)

    @env1 = {
      "REQUEST_PATH" => "/",
      "rack.session" => {},
      "PATH_INFO" => "/",
      "REQUEST_URI" => "/",
      "REQUEST_METHOD" => "POST",
      "rack.input" => Rack::Lint::InputWrapper.new(StringIO.new)
    }

    @env2 = {
      "REQUEST_PATH" => "/path/elem",
      "rack.session" => {},
      "PATH_INFO" => "/path/elem",
      "REQUEST_URI" => "/path/elem",
      "REQUEST_METHOD" => "POST",
      "rack.input" => Rack::Lint::InputWrapper.new(StringIO.new)
    }
  end

  it "sends 403 if render_with is not provided and the key is wrong" do
    @env1["REQUEST_URI"] = "/?csrf=abc1234"
    @env1["rack.session"]["csrf"] = "abc123"
    @env1["QUERY_STRING"] = "csrf=abc1234"

    expect(described_class.new(app).call(@env1)).to eq \
      [403, {}, ["Unauthorized"]]
  end

  it "sends 403 by default without render_with" do
    expect(described_class.new(app).call(@env1)).to eq \
      [403, {}, ["Unauthorized"]]
  end

  it "accepts the X_CSRF_TOKEN header" do
    @env1["rack.session"]["csrf"] = "abc123"
    @env1["HTTP_X_CSRF_TOKEN"] = "abc123"

    expect(described_class.new(app).call(@env1)).to eq true
  end

  it "accepts a normal auth token" do
    @env1["REQUEST_URI"] = "/?auth=abc123"
    @env1["QUERY_STRING"] = "auth=abc123"
    @env1["rack.session"]["csrf"] = "abc123"
    expect(described_class.new(app).call(@env1)).to eq true
  end

  it "raises if there is no session" do
    @env1.delete("rack.session")

    expect { described_class.new(app).call(@env1) }.to raise_error \
      described_class::CSRFSessionUnavailableError
  end

  it "creates a new csrf key" do
    expect(@env1["rack.session"]["csrf"]).to be_nil
    described_class.new(app, :skip => ["/"]).call(@env1)
    expect(@env1["rack.session"]["csrf"].length).to eq 64
  end

  context "with a skip list" do
    it "allows METHOD:PATH" do
      expect(described_class.new(app, :skip => \
        ["POST:/"]).call(@env1)).to eq true
    end

    it "allows regexp" do
      expect(described_class.new(app, :skip => \
        ["POST:/path/.*"]).call(@env2)).to eq true
    end

    it "allows a basic path" do
      expect(described_class.new(app, :skip => \
        ["/"]).call(@env1)).to eq true
    end

    it "sends a 403 on [].empty? == true" do
      expect(described_class.new(app, :skip => \
        []).call(@env1)).to eq [403, {}, ["Unauthorized"]]
    end

    it "sends a 403 on bad path" do
      expect(described_class.new(app, :skip => \
        ["POST:/path"]).call(@env2)).to eq [403, {}, ["Unauthorized"]]
    end

    it "allows when multiple skips" do
      expect(described_class.new(app, :skip => \
        ["POST:/path", "PUT:/path/elem", "POST:/path/elem"]).call(@env2)).to eq true
    end
  end

  it "doesn't mix up HTTP METHODS" do
    expect(described_class.new(app, :skip => \
      ["GET:/"]).call(@env1)).to eq [403, {}, ["Unauthorized"]]
  end

  context "with raise set to true" do
    it "raises if doing a post on a new session" do
      expect { described_class.new(app, :raise => true).call(@env1) }.to \
        raise_error described_class::CSRFFailedToValidateError
    end

    it "raises if the csrf key does not match" do
      @env1["REQUEST_URI"] = "/?csrf=abc1234"
      @env1["QUERY_STRING"] = "csrf=abc1234"
      @env1["rack.session"]["csrf"] = "abc123"

      expect { described_class.new(app, :raise => true).call(@env1) }.to \
        raise_error described_class::CSRFFailedToValidateError
    end
  end

  context "with raise set to false" do
    context "render_with set with a proc in opts" do
      it "should call the proc" do
        err = [403, {}, ["Abc123"]]
        expect(described_class.new(app, :render_with => \
          proc { |e| err }).call(@env1)).to eq err
      end
    end
  end
end

describe Rack::SimpleCsrf::Helpers do
  before :each do
    allow(described_class).to receive(:session).and_return("csrf" => "abc123")
  end

  describe "#csrf_meta_tag" do
    let(:value) { %Q{<meta name="auth" content="abc123">} }

    it "outputs a meta tag" do
      expect(described_class.csrf_meta_tag).to eq \
        %{<meta name="auth" content="abc123">}
    end

    it "allows a custom field name" do
      expect(described_class.csrf_meta_tag(:field => "my_field")).to eq \
        %{<meta name="my_field" content="abc123">}
    end
  end

  describe "#csrf_form_tag" do
    it "should output an input wrapped in a div" do
      expect(described_class.csrf_form_tag).to eq <<-STR.strip_heredoc
        <div class="hidden">
          <input type="hidden" name="auth" value="abc123">
        </div>
      STR
    end

    it "accepts a custom tag" do
      expect(described_class.csrf_form_tag(:tag => "section")).to eq \
      <<-STR.strip_heredoc
        <section class="hidden">
          <input type="hidden" name="auth" value="abc123">
        </section>
      STR
    end

    it "accepts a custom field name" do
      expect(described_class.csrf_form_tag(:field => "my_field")).to eq \
      <<-STR.strip_heredoc
        <div class="hidden">
          <input type="hidden" name="my_field" value="abc123">
        </div>
      STR
    end
  end
end
