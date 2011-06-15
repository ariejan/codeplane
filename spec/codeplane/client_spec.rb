require "spec_helper"

describe Codeplane::Client do
  describe "#repositories" do
    let(:collection) { :repositories }
    let(:resource_path) { "/repositories" }
    let(:resource_class_name) { "Repository" }
    let(:resource_class) { Codeplane::Resource::Repository }

    it_behaves_like "resource collection"
  end

  describe "#public_keys" do
    let(:collection) { :public_keys }
    let(:resource_path) { "/public_keys" }
    let(:resource_class_name) { "PublicKey" }
    let(:resource_class) { Codeplane::Resource::PublicKey }

    it_behaves_like "resource collection"
  end
end
