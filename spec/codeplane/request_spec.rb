require "spec_helper"

describe Codeplane::Request do
  context "request shortcuts" do
    it "implements GET" do
      subject.should respond_to(:get)
    end

    it "implements POST" do
      subject.should respond_to(:post)
    end

    it "implements PUT" do
      subject.should respond_to(:put)
    end

    it "implements DELETE" do
      subject.should respond_to(:delete)
    end
  end

  describe "#net_class" do
    it "detects GET" do
      subject.net_class(:Get).should == Net::HTTP::Get
    end

    it "detects POST" do
      subject.net_class(:Post).should == Net::HTTP::Post
    end

    it "detects PUT" do
      subject.net_class(:Put).should == Net::HTTP::Put
    end

    it "detects DELETE" do
      subject.net_class(:Delete).should == Net::HTTP::Delete
    end
  end

  describe "#request" do
    before do
      ENV["CODEPLANE_ENDPOINT"] = "https://example.com"
      FakeWeb.register_uri :any, "https://example.com", :status => 200
    end

    it "sets request as HTTPS" do
      subject.get("/")
      request = FakeWeb.last_request
    end

    it "sets user agent" do
      subject.get("/")
      FakeWeb.last_request["User-Agent"].should == "Codeplane/#{Codeplane::Version::STRING}"
    end

    it "sets content type" do
      subject.get("/")
      FakeWeb.last_request["Content-Type"].should == "application/x-www-form-urlencoded"
    end

    it "sets body" do
      subject.post("/", :repository => {:name => "myrepo"})
      FakeWeb.last_request.body.should == "repository[name]=myrepo"
    end

    it "sets credentials" do
      Codeplane.configure do |config|
        config.username = "john"
        config.api_key = "abc"
      end

      FakeWeb.register_uri :any, "https://john:abc@example.com", :status => 200
      subject.get("/")
      FakeWeb.last_request["authorization"].should == "Basic " + Base64.encode64("john:abc").chomp
    end

    it "returns a response object" do
      subject.get("/").should be_a(Codeplane::Response)
    end

    it "detects 401 status" do
      FakeWeb.register_uri :any, "https://example.com", :status => 401

      expect {
        subject.get("/")
      }.to raise_error(Codeplane::UnauthorizedError)
    end


    it "detects 404 status" do
      FakeWeb.register_uri :any, "https://example.com", :status => 404

      expect {
        subject.get("/")
      }.to raise_error(Codeplane::NotFoundError)
    end
  end
end
