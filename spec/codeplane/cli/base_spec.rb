require "spec_helper"

describe Codeplane::CLI::Base do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
  end

  describe "#confirmed?" do
    subject { Codeplane::CLI::Base.new }

    it "bypasses confirmation" do
      subject.args = ["--confirm"]
      subject.should be_confirmed
    end

    it "accepts 'y' as confirmation" do
      subject.args = []

      subject.should_receive(:gets).and_return("y\n")
      subject.should be_confirmed
    end

    it "accepts 'yes' as confirmation" do
      subject.args = []

      subject.should_receive(:gets).and_return("yes\n")
      subject.should be_confirmed
    end

    it "rejects anything else" do
      subject.args = []

      subject.should_receive(:gets).and_return("n\n")

      expect { subject.should_not be_confirmed }.to raise_error(SystemExit)

      Codeplane::CLI.stdout.should include("Not doing anything")
    end
  end
end
