require "spec_helper"

describe Codeplane::Resource::Repository do
  subject { Codeplane::Resource::Repository.new(:id => 1234, :name => "macbook") }

  describe "#collaborators" do
    let(:collection) { :collaborators }
    let(:resource_path) { "/repositories/1234/collaborators" }
    let(:resource_class_name) { "User" }
    let(:resource_class) { Codeplane::Resource::User }

    it_behaves_like "resource collection"
  end

  describe "#mine?" do
    it "returns true" do
      Codeplane.username = "john"
      subject = Codeplane::Resource::Repository.new(:user => {:username => "john"})
      subject.should be_mine
    end

    it "returns false" do
      Codeplane.username = "mary"
      subject = Codeplane::Resource::Repository.new(:user => {:username => "john"})
      subject.should_not be_mine
    end
  end

  describe "#destroy" do
    it "raises error when trying to remove a repository that's not mine" do
      Codeplane.username = "mary"
      subject = Codeplane::Resource::Repository.new(:user => {:username => "john"})

      expect {
        subject.destroy
      }.to raise_error(Codeplane::OwnershipError)
    end

    it "removes my repository" do
      FakeWeb.register_uri :delete, "https://john:abc@codeplane.com/api/v1/repositories/1234", :status => 200
      default_credentials!
      subject = Codeplane::Resource::Repository.new(:id => 1234, :user => {:username => "john"}, :collection_resource_path => "/repositories")
      subject.destroy
    end
  end

  describe "#attributes" do
    it { should respond_to(:id) }
    it { should respond_to(:name) }
    it { should respond_to(:usage) }
    it { should respond_to(:created_at) }
    it { should respond_to(:user) }
    it { should respond_to(:errors) }
    it { should respond_to(:uri) }

    it {
      expect {
        subject.attributes
      }.to_not raise_error
    }

    its(:attributes) {
      should == {:repository => {:name => "macbook"}}
    }
  end
end
