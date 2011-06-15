require "spec_helper"

describe Codeplane::Resource::Repository, "#collaborators" do
  before do
    default_credentials!
  end

  subject { Codeplane::Resource::Repository.new(:id => 1234) }

  it "includes extension" do
    subject.collaborators.singleton_class.included_modules.should include(Codeplane::Resource::Extensions::Collaborator)
  end

  it "does not respond to create" do
    subject.collaborators.should_not respond_to(:create)
  end

  it "responds to invite" do
    subject.collaborators.should respond_to(:invite)
  end

  it "responds to remove" do
    subject.collaborators.should respond_to(:remove)
  end

  describe "#remove" do
    context "with existing collaborator" do
      before do
        FakeWeb.register_uri :get, "https://john:abc@codeplane.com/api/v1/repositories/1234/collaborators", :body => [{:id => 5678, :email => "john@doe.com"}].to_json
        FakeWeb.register_uri :delete, "https://john:abc@codeplane.com/api/v1/repositories/1234/collaborators/5678", :status => 200
      end

      subject {
        Codeplane::Resource::Repository.new(:id => 1234).collaborators.remove("john@doe.com")
      }

      it "makes a DELETE request" do
        subject
        FakeWeb.last_request.should be_a(Net::HTTP::Delete)
      end

      it "returns true" do
        subject.should be_true
      end
    end

    context "with missing collaborator" do
      before do
        FakeWeb.register_uri :get, "https://john:abc@codeplane.com/api/v1/repositories/1234/collaborators", :body => [{:id => 5678, :email => "john@doe.com"}].to_json
        FakeWeb.register_uri :delete, "https://john:abc@codeplane.com/api/v1/repositories/1234/collaborators/5678", :status => 404
      end

      subject {
        Codeplane::Resource::Repository.new(:id => 1234).collaborators.remove("mary@doe.com")
      }

      it "raises exception" do
        expect { subject }.to raise_error(Codeplane::NotFoundError)
      end
    end
  end

  describe "#invite" do
    context "with valid data" do
      before do
        FakeWeb.register_uri :post, "https://john:abc@codeplane.com/api/v1/repositories/1234/collaborators", :body => {:email => "john@doe.com", :errors => []}.to_json, :status => 201
      end

      subject {
        Codeplane::Resource::Repository.new(:id => 1234).collaborators.invite("john@doe.com")
      }

      its(:email) { should == "john@doe.com" }
      its(:errors) { should be_an(Array) }

      it { subject.should be_valid }

      it "returns an invitation instance" do
        subject.should be_an(Codeplane::Resource::Invitation)
      end

      it "makes a POST request" do
        FakeWeb.last_request.should be_a(Net::HTTP::Post)
        request_body.should == {"collaborator" => {"email" => "john@doe.com"}}
      end
    end

    context "with invalid data" do
      before do
        FakeWeb.register_uri :post, "https://john:abc@codeplane.com/api/v1/repositories/1234/collaborators", :body => {:email => "john", :errors => ["Email is invalid"]}.to_json, :status => 201
      end

      subject {
        Codeplane::Resource::Repository.new(:id => 1234).collaborators.invite("john@doe.com")
      }

      it { subject.should_not be_valid }

      it "includes error messages" do
        subject.errors.should include("Email is invalid")
      end
    end
  end
end
