require "spec_helper"

describe Codeplane::CLI::Repo do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
    subject.client.repositories.stub :all => []
  end

  describe "#add" do
    it "displays message" do
      subject.client.repositories.stub :create => stub(:valid? => true, :uri => "repo.git")
      expect { subject.add }.to raise_error(SystemExit)
      Codeplane::CLI.stdout.should include("Your Git url is repo.git\nGive it some time before cloning it.")
    end

    it "displays error message" do
      subject.client.repositories.stub :create => stub(:valid? => false, :errors => ["Something is wrong"])
      expect { subject.add }.to raise_error(SystemExit)
      Codeplane::CLI.stderr.should include("* Something is wrong")
    end
  end

  describe "#remove" do
    before do
      subject.args = ["some-repo"]
      subject.stub :confirmed? => true
    end

    it "exits when have no repositories" do
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.remove }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("No repositories found")
    end

    it "displays message" do
      repo = stub(:mine? => true, :name => "some-repo")
      subject.client.repositories.stub :all => [repo]

      repo.should_receive(:destroy).once

      expect { subject.remove }.to raise_error(SystemExit)
      Codeplane::CLI.stdout.should include("The repository 'some-repo' has been removed")
    end

    it "exits when no name is provided" do
      subject.args = []
      expect { subject.remove }.to raise_error(SystemExit)
      Codeplane::CLI.stderr.should include("Provide the repository name")
    end

    it "exits when repository is not found" do
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      subject.client.repositories.stub :all => [stub(:name => "repo-1")]
      subject.args = ["repo-2"]

      expect { subject.remove }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("Couldn't find 'repo-2' repository")
    end

    it "exits when removing shared repo" do
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      subject.client.repositories.stub :all => [stub(:name => "repo-1", :mine? => false)]
      subject.args = ["repo-1"]

      expect { subject.remove }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("You can't remove 'repo-1' because you don't own it")
    end
  end

  describe "#list" do
    it "exits when have no repositories" do
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("No repositories found")
    end

    it "displays repository list" do
      subject.client.repositories.stub :all => [
        stub(:name => "repo-1", :mine? => true, :uri => "repo-1.git"),
        stub(:name => "shared-repo", :mine? => false, :uri => "shared-repo.git")
      ]

      subject.list
      clean(Codeplane::CLI.stdout).should include("repo-1          # repo-1.git")
      clean(Codeplane::CLI.stdout).should include("shared-repo*    # shared-repo.git")
    end
  end

  describe "#info" do
    it "exits when no name is provided" do
      subject.args = []
      expect { subject.info }.to raise_error(SystemExit)
      Codeplane::CLI.stderr.should include("Provide the repository name")
    end

    it "exits when repository is not found" do
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      subject.client.repositories.stub :all => [stub(:name => "repo-1")]
      subject.args = ["repo-2"]

      expect { subject.info }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("Couldn't find repository 'repo-2'")
    end

    it "displays repository info" do
      subject.client.repositories.stub :all => [
        stub(:name => "repo-1", :mine? => true, :uri => "repo-1.git", :usage => 0)
      ]

      subject.args = ["repo-1"]
      expect { subject.info }.to raise_error(SystemExit)

      Codeplane::CLI.stdout.should include("Name: repo-1")
      Codeplane::CLI.stdout.should include("Git url: repo-1.git")
      Codeplane::CLI.stdout.should include("Usage: 0 bytes")
      Codeplane::CLI.stdout.should include("Owner: You")
    end

    it "displays shared repository info" do
      subject.client.repositories.stub :all => [
        stub(
          :name => "repo-1",
          :usage => 0,
          :user => stub(:name => "John Doe", :email => "john@doe.com"),
          :mine? => false
        ).as_null_object
      ]

      subject.args = ["repo-1"]
      expect { subject.info }.to raise_error(SystemExit)

      Codeplane::CLI.stdout.should include("Owner: John Doe (john@doe.com)")
    end
  end
end
