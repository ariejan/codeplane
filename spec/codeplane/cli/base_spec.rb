require "spec_helper"

describe Codeplane::CLI::Base do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
  end

  describe "#run" do
    it "raises unauthorized exception when credentials aren't set" do
      Codeplane::CLI.stub :credentials? => false

      expect {
        Codeplane::CLI::Repo.new([]).run("base")
      }.to raise_error(Codeplane::UnauthorizedError)
    end

    it "executes command when credentials are set" do
      Codeplane::CLI.stub :credentials? => true
      Codeplane::CLI::Repo.any_instance.should_receive(:base)

      expect {
        Codeplane::CLI::Repo.new([]).run("base")
      }.to_not raise_error
    end

    it "executes command when running setup" do
      Codeplane::CLI.stub :credentials? => true
      Codeplane::CLI::Setup.any_instance.should_receive(:base)

      expect {
        Codeplane::CLI::Setup.new([]).run("base")
      }.to_not raise_error
    end
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
