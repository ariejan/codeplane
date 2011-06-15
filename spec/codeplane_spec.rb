require "spec_helper"

describe Codeplane do
  describe ".configure" do
    it "sets username" do
      Codeplane.configure {|c| c.username = "johndoe"}
      Codeplane.username.should == "johndoe"
    end

    it "sets API key" do
      Codeplane.configure {|c| c.api_key = "abc"}
      Codeplane.api_key.should == "abc"
    end
  end

  describe ".endpoint" do
    it "returns real url" do
      ENV.delete("CODEPLANE_ENDPOINT")
      Codeplane.endpoint.should == "https://codeplane.com/api/v1"
    end

    it "returns alternative url" do
      ENV["CODEPLANE_ENDPOINT"] = "http://example.com"
      Codeplane.endpoint.should == "http://example.com"
    end
  end
end
