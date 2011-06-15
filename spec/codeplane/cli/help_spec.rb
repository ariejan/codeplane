require "spec_helper"

describe Codeplane::CLI::Help do
  before do
    Codeplane::CLI.stdout = StringIO.new
    Codeplane::CLI.stderr = StringIO.new
  end

  it "displays help for all known commands" do
    Codeplane::CLI::Help.should_receive(:help).ordered.once
    Codeplane::CLI::Setup.should_receive(:help).ordered.once
    Codeplane::CLI::Auth.should_receive(:help).ordered.once
    Codeplane::CLI::Repo.should_receive(:help).ordered.once
    Codeplane::CLI::User.should_receive(:help).ordered.once

    subject.base
  end

  it "displays help specified command" do
    Codeplane::CLI::Setup.should_receive(:help).once
    Codeplane::CLI::Help.should_not_receive(:help)
    Codeplane::CLI::Auth.should_not_receive(:help)
    Codeplane::CLI::Repo.should_not_receive(:help)
    Codeplane::CLI::User.should_not_receive(:help)

    subject = Codeplane::CLI::Help.new(%w[setup])
    subject.base
  end

  it "display help's help for invalid commands" do
    Codeplane::CLI::Help.should_receive(:help).once
    Codeplane::CLI::Setup.should_not_receive(:help)
    Codeplane::CLI::Auth.should_not_receive(:help)
    Codeplane::CLI::Repo.should_not_receive(:help)
    Codeplane::CLI::User.should_not_receive(:help)

    subject = Codeplane::CLI::Help.new(%w[invalid])
    subject.should_receive(:exit).with(1).and_raise(SystemExit)

    expect {
      subject.base
    }.to raise_error(SystemExit)
  end
end
