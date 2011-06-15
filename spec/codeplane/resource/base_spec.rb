require "spec_helper"

describe Codeplane::Resource::Base do
  its(:errors) { should be_an(Array) }

  describe "#attributes" do
    it "raises error" do
      expect {
        subject.attributes
      }.to raise_error(Codeplane::AbstractMethodError)
    end
  end

  describe "#valid?" do
    it "returns true" do
      subject.should be_valid
    end

    it "return false" do
      subject.errors << "Something is wrong"
      subject.should_not be_valid
    end
  end

  describe "#new_record?" do
    it "returns true" do
      subject = Codeplane::Resource::Thing.new
      subject.should be_new_record
    end

    it "returns false" do
      subject = Codeplane::Resource::Thing.new(:id => 1234)
      subject.should_not be_new_record
    end
  end

  context "coersion" do
    it "converts created_at stamps" do
      now = Time.now
      resource = Codeplane::Resource::Thing.new(:created_at => now.iso8601)
      resource.created_at.to_s.should == now.to_s
    end

    it "ignores empty created_at stamp" do
      expect {
        resource = Codeplane::Resource::Thing.new(:created_at => nil)
        resource.created_at.should be_nil
      }.to_not raise_error
    end

    it "converts user" do
      resource = Codeplane::Resource::Thing.new(:user => {:name => "John Doe", :id => 1})
      resource.user.should be_an(Codeplane::Resource::User)
      resource.user.name.should == "John Doe"
      resource.user.id.should == 1
    end

    it "ignores empty user payload" do
      expect {
        resource = Codeplane::Resource::Thing.new(:user => nil)
        resource.user.should be_nil
      }.to_not raise_error
    end
  end

  describe "#save" do
    before do
      default_credentials!
    end

    context "new resource" do
      subject {
        Codeplane::Resource::Thing.new(:name => "tv", :collection_resource_path => "/things")
      }

      before do
        FakeWeb.register_uri :post, "https://john:abc@codeplane.com/api/v1/things",
          :status => 201, :body => fixtures.join("thing.json").read
        subject.save
      end

      it "makes a POST request" do
        FakeWeb.last_request.should be_a(Net::HTTP::Post)
      end

      it "sets request body" do
        request_body.should == {"thing" => {"name" => "tv"}}
      end

      it "updates object" do
        subject.id.should == 1
      end
    end

    context "existing resource" do
      subject {
        Codeplane::Resource::Thing.new(:name => "tv", :collection_resource_path => "/things", :id => 1234)
      }

      before do
        FakeWeb.register_uri :put, "https://john:abc@codeplane.com/api/v1/things/1234",
          :status => 200, :body => fixtures.join("thing.json").read
        subject.save
      end

      it "makes a PUT request" do
        FakeWeb.last_request.should be_a(Net::HTTP::Put)
      end

      it "sets request body" do
        request_body.should == {"thing" => {"name" => "tv"}}
      end
    end
  end

  describe "#save" do
    before do
      default_credentials!
    end

    context "new resource" do
      subject {
        Codeplane::Resource::Thing.new(:name => "tv", :collection_resource_path => "/things")
      }

      it "raises error" do
        expect {
          subject.destroy
        }.to raise_error(Codeplane::UnsavedResourceError)
      end
    end

    context "existing resource" do
      subject {
        Codeplane::Resource::Thing.new(:name => "tv", :collection_resource_path => "/things", :id => 1234)
      }

      before do
        FakeWeb.register_uri :delete, "https://john:abc@codeplane.com/api/v1/things/1234",
          :status => 200
        subject.destroy
      end

      it "makes a DELETE request" do
        FakeWeb.last_request.should be_a(Net::HTTP::Delete)
      end
    end
  end
end
