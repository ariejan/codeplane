require "spec_helper"

describe Codeplane::CLI::Setup do
  before do
    Codeplane::CLI.stub :config_file => "/tmp/codeplane_config"
    FileUtils.rm(Codeplane::CLI.config_file) rescue nil

    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
    Codeplane::Request.stub :get
    subject.stub :gets => ""
  end

  it "sets credentials" do
    subject.should_receive(:gets).and_return("the_real_john\n", "some_api_key\n")
    subject.base

    Codeplane.username.should == "the_real_john"
    Codeplane.api_key.should == "some_api_key"
  end

  it "makes API call" do
    Codeplane::Request.should_receive(:get).with("/auth")
    subject.base
  end

  it "displays success message" do
    expect {
      subject.base
    }.to_not raise_error

    Codeplane::CLI.stdout.should include("Your credentials were saved at ~/.codeplane and chmoded as 0600.")
  end

  it "saves credentials to filesystem" do
    subject.should_receive(:gets).and_return("the_real_john\n", "some_api_key\n")
    subject.base

    File.should be_file(Codeplane::CLI.config_file)
    YAML.load_file(Codeplane::CLI.config_file).should == {:username => "the_real_john", :api_key => "some_api_key"}
    File.should_not be_world_writable(Codeplane::CLI.config_file)
    File.should_not be_world_readable(Codeplane::CLI.config_file)
  end
end
