require "spec_helper"

describe Codeplane::Resource::User do
  subject { Codeplane::Resource::User.new }

  describe "#attributes" do
    it { should respond_to(:id) }
    it { should respond_to(:username) }
    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:usage) }
    it { should respond_to(:storage) }
    it { should respond_to(:created_at) }
    it { should respond_to(:time_zone) }
  end

  context "remove methods" do
    it { should_not respond_to(:save) }
    it { should_not respond_to(:attributes) }
    it { should_not respond_to(:resource_path) }
  end
end
