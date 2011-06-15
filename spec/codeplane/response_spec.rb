require "spec_helper"

describe Codeplane::Response do
  it "returns status code" do
    subject.stub_chain(:raw, :code => "200")
    subject.status.should == 200
  end

  it "parses payload" do
    subject.stub_chain(:raw, :body => {:success => true}.to_json)
    subject.payload.should == {"success" => true}
  end

  it "detects success status" do
    subject.stub_chain(:raw, :code => "204")
    subject.should be_success
  end

  it "detects redirect status" do
    subject.stub_chain(:raw, :code => "302")
    subject.should be_redirect
  end

  it "detects error status" do
    subject.stub_chain(:raw, :code => "500")
    subject.should be_error
  end
end
