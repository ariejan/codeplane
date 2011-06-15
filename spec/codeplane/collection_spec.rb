require "spec_helper"

describe Codeplane::Collection do
  subject {
    Codeplane::Collection.new(
      :resource_path => "/things",
      :resource_class_name => "Thing"
    )
  }

  describe "#initialize" do
    its(:resource_path) { should == "/things" }
    its(:resource_class_name) { should == "Thing" }

    it "includes extension" do
      mod = Module.new
      Codeplane::Collection.new(:extension => mod).singleton_class.included_modules.should include(mod)
    end
  end

  describe "#resource_class" do
    it "retrieves specified class" do
      subject.resource_class_name = "Thing"
      subject.resource_class.should == Codeplane::Resource::Thing
    end
  end

  describe "#all" do
    before do
      default_credentials!
      FakeWeb.register_uri :get, "https://john:abc@codeplane.com/api/v1/things", :body => fixtures.join("things.json").read
    end

    it "retrieves all items" do
      subject.all.size.should == 3
    end

    it "builds objects" do
      subject.all[0].should be_a(Codeplane::Resource::Thing)
      subject.all[1].should be_a(Codeplane::Resource::Thing)
      subject.all[2].should be_a(Codeplane::Resource::Thing)
    end

    it "sets attributes" do
      thing = subject.all[0]
      thing.name.should == "macbook"
      thing.id.should == 1
      thing.collection_resource_path.should == "/things"
    end
  end

  describe "#each" do
    it "includes Enumerable" do
      Codeplane::Collection.included_modules.should include(Enumerable)
    end

    it "returns an enumerator" do
      default_credentials!
      FakeWeb.register_uri :get, "https://john:abc@codeplane.com/api/v1/things", :body => "[]"
      subject.each.should be_an(Enumerator)
    end
  end

  describe "#build" do
    it "returns a resource instance" do
      subject.build.should be_a(Codeplane::Resource::Thing)
    end

    it "sets attributes" do
      thing = subject.build(:name => "book")
      thing.name.should == "book"
    end
  end

  describe "#create" do
    it "builds a new instance" do
      subject.should_receive(:build).with(:name => "book").and_return(stub.as_null_object)
      subject.create(:name => "book")
    end

    it "calls the #save method" do
      thing = mock(Codeplane::Resource::Thing)
      subject.stub :build => thing

      thing.should_receive(:save).once
      subject.create
    end
  end

  describe "#count" do
    before { subject.stub :all => [1,2,3] }

    its(:count) { should == 3 }
    its(:size) { should == 3 }
  end
end
