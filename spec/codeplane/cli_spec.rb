require "spec_helper"

describe Codeplane::CLI do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  it "sets config file path" do
    Codeplane::CLI.config_file.should == File.expand_path("~/.codeplane")
  end

  context "exception handling" do
    it "wraps Codeplane::UnauthorizedError" do
      Codeplane::CLI.should_receive(:command_class_for).and_raise(Codeplane::UnauthorizedError)
      Codeplane::CLI.should_receive(:exit).with(1).and_raise(SystemExit)

      expect {
        Codeplane::CLI.start(%w[setup], "", "")
      }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("We couldn't authenticate you. Double check your credentials.")
    end

    it "wraps uncaught exceptions" do
      Codeplane::CLI.should_receive(:command_class_for).and_raise(Exception)
      Codeplane::CLI.should_receive(:exit).with(1).and_raise(SystemExit)

      expect {
        Codeplane::CLI.start([], "", "")
      }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("Something went wrong.")
    end
  end

  context "invalid commands" do
    it "displays help for empty args" do
      Codeplane::CLI::Help.should_receive(:help).once
      Codeplane::CLI.start([], stdout, stderr)
    end

    it "displays help" do
      Codeplane::CLI::Help.should_receive(:help).once

      expect {
        Codeplane::CLI.start(%w[invalid:command], stdout, stderr)
      }.to raise_error
    end

    it "exits" do
      Codeplane::CLI::Help.any_instance.should_receive(:exit).with(1).and_raise(SystemExit)

      expect {
        Codeplane::CLI.start(%w[invalid:command], stdout, stderr)
      }.to raise_error(SystemExit)
    end
  end

  context "subcommand" do
    it "executes original argument" do
      Codeplane::CLI::Setup.any_instance.should_receive(:perform).once
      Codeplane::CLI.start(%w[setup:perform], stdout, stderr)
    end

    it "defaults to base when available" do
      Codeplane::CLI::Setup.any_instance.should_receive(:respond_to?).and_return(true)
      Codeplane::CLI::Setup.any_instance.should_receive(:base).once
      Codeplane::CLI.start(%w[setup], stdout, stderr)
    end

    it "executes help command when don't respond to base" do
      Codeplane::CLI::Setup.any_instance.should_receive(:respond_to?).and_return(false)
      Codeplane::CLI::Setup.should_receive(:help).once

      expect {
        Codeplane::CLI.start(%w[setup], stdout, stderr)
      }.to raise_error
    end
  end
end
