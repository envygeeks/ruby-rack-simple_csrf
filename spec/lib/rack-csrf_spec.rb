require "rspec/helper"

describe Rack::Csrf do
  let(:app) { Class.new }
  let(:method) { "POST" }
  let(:path) { "/" }

  before :each do
    app.stub(:call).and_return(true)

    @env = {
      "REQUEST_PATH" => "#{path}",
      "PATH_INFO" => "#{path}",
      "rack.session" => {},
      "REQUEST_URI" => "#{path}",
      "REQUEST_METHOD" => "#{method}",
      "rack.input" => Rack::Lint::InputWrapper.new(StringIO.new)
    }
  end

  describe "#call" do
    it "should raise if there is no session" do
      @env.delete("rack.session")
      expect do
        Rack::Csrf.new(app).call(@env)
      end.to raise_error Rack::Csrf::CSRFSessionUnavailableError
    end

    it "should create a csrf key if there is not one" do
      @env["rack.session"][Rack::Csrf.key].should be_nil
      Rack::Csrf.new(app, skip: ["/"]).call(@env)
      @env["rack.session"][Rack::Csrf.key].length.should eq 64
    end
  end

  describe "#continue?" do
    context "through #call" do
      context "with raise set to true" do
        it "should raise if posting on a new session" do
          expect do
            Rack::Csrf.new(app, raise: true).call(@env)
          end.to raise_error Rack::Csrf::CSRFFailedToValidateError
        end

        it "should raise if the session key does not match" do
          @env["REQUEST_URI"] = "/?#{Rack::Csrf.key}=abc1234"
          @env["QUERY_STRING"] = "#{Rack::Csrf.key}=abc1234"
          @env["rack.session"][Rack::Csrf.key] = "abc123"

          expect do
            Rack::Csrf.new(app, raise: true).call(@env)
          end.to raise_error Rack::Csrf::CSRFFailedToValidateError
        end
      end

      context "with raise set to false" do
        context "render_with set with a proc in opts" do
          it "should call the proc" do
            err = [403, {}, ["Abc123"]]
            Rack::Csrf.new(app, render_with:
              Proc.new { |env| err }).call(@env).should eq err
          end
        end

        context "without render_with, or with it not set to a proc" do
          it "should set 401 w/ unauthorized if posting on a new session" do
            Rack::Csrf.new(app).call(@env).should eq [403, {},["Unauthorized"]]
          end

          it "should set 401 unauthorized if the session key doesn't match" do
            @env["REQUEST_URI"] = "/?#{Rack::Csrf.key}=abc1234"
            @env["QUERY_STRING"] = "#{Rack::Csrf.key}=abc1234"
            @env["rack.session"][Rack::Csrf.key] = "abc123"
            Rack::Csrf.new(app).call(
              @env).should eq [403, {}, ["Unauthorized"]]
          end
        end
      end

      it "should accept the X_CSRF_TOKEN header" do
        @env["rack.session"][Rack::Csrf.key] = "abc123"
        @env[Rack::Csrf.header] = "abc123"
        Rack::Csrf.new(app).call(@env).should be_true
      end

      it "should accept a normal token" do
        @env["REQUEST_URI"] = "/?#{Rack::Csrf.field}=abc123"
        @env["QUERY_STRING"] = "#{Rack::Csrf.field}=abc123"
        @env["rack.session"][Rack::Csrf.key] = "abc123"
        Rack::Csrf.new(app).call(@env).should be_true
      end
    end
  end
end

describe Rack::Csrf::Helpers do
  let(:tag) { Rack::Csrf.tag }
  let(:field) { Rack::Csrf.field }
  let(:key) { Rack::Csrf.key }
  let(:token) { "abc123" }

  class TheCls
    include Rack::Csrf::Helpers
  end

  before :each do
    Rack::Csrf::Helpers.stub(:session).and_return({ key => token })
    TheCls.any_instance.stub(:session).and_return({ key => token })
  end

  describe "#csrf_meta_tag" do
    let(:value) { %Q{<meta name="#{field}" content="#{token}">} }

    context "without opts" do
      it "should work" do
        TheCls.new.csrf_meta_tag.should eq value
        Rack::Csrf::Helpers.csrf_meta_tag.should eq value
      end
    end

    context "with a custom field" do
      let(:field) { "my_field" }

      it "should work" do
        TheCls.new.csrf_meta_tag(field: field).should eq value
        Rack::Csrf::Helpers.csrf_meta_tag(field: field).should eq value
      end
    end
  end

  describe "#csrf_form_tag" do
    let(:tag) { "section" }

    let(:value) {
      <<-STR.split("\n").map { |s| s.gsub(/^\s+/, "") }.join
        <#{tag} class="hidden">
          <input type="hidden" name="#{field}" value="#{token}">
        </#{tag}>
      STR
    }

    context "without opts" do
      it "should work" do
        TheCls.new.csrf_form_tag.should eq value
        Rack::Csrf::Helpers.csrf_form_tag.should eq value
      end
    end

    context "with a custom tag" do
      let(:tag) { "div" }

      it "should work" do
        TheCls.new.csrf_form_tag(tag: tag).should eq value
        Rack::Csrf::Helpers.csrf_form_tag(tag: tag).should eq value
      end
    end

    context "with a custom field" do
      let(:field) { "my_field" }

      it "should work" do
        TheCls.new.csrf_form_tag(field: field).should eq value
        Rack::Csrf::Helpers.csrf_form_tag(field: field).should eq value
      end
    end
  end
end
