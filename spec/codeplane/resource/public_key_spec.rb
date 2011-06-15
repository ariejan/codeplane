require "spec_helper"

describe Codeplane::Resource::PublicKey do
  subject { Codeplane::Resource::PublicKey.new(:id => 1234, :name => "macbook's", :key => "ssh-rsa key") }

  describe "#attributes" do
    it { should respond_to(:id) }
    it { should respond_to(:name) }
    it { should respond_to(:key) }
    it { should respond_to(:fingerprint) }
    it { should respond_to(:errors) }

    it {
      expect {
        subject.attributes
      }.to_not raise_error
    }

    its(:attributes) {
      should == {:public_key => {
        :name => "macbook's",
        :key => "ssh-rsa key"
      }}
    }
  end
end
