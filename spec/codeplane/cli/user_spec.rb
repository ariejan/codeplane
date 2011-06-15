require "spec_helper"

describe Codeplane::CLI::User do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
    subject.client.repositories.stub :all => [
      stub(:name => "repo", :mine? => true, :collaborators => stub(:all => []))
    ]

    subject.args = ["repo"]
  end

  describe "#list" do
    it "lists collaborators" do
      subject.client.repositories.first.collaborators.stub :all => [
        stub(:name => "John Doe", :email => "john@doe.com"),
        stub(:name => "Tim Doe", :email => "tim@doe.com")
      ]

      subject.list

      clean(Codeplane::CLI.stdout).should include("John Doe    # john@doe.com")
      clean(Codeplane::CLI.stdout).should include("Tim Doe     # tim@doe.com")
    end

    it "exits when have no collaborators" do
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("No collaborators were added to 'repo'")
    end

    it "exits when trying to list shared repository's collaborators" do
      subject.client.repositories.first.collaborators.stub :all => [
        stub(:name => "John Doe", :email => "john@doe.com")
      ]
      subject.client.repositories.first.stub :mine? => false
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("Couldn't find 'repo' repository")
    end

    it "exits when repository is not found" do
      subject.args = ["another-repo"]
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("Couldn't find 'another-repo' repository")
    end

    it "exits when no repository name is provided" do
      subject.args = []
      subject.should_receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      Codeplane::CLI.stderr.should include("Provide the repository name")
    end
  end

  describe "#add" do
    it "displays message" do
      subject.args = ["repo", "john@doe.com"]
      subject.client.repositories.all.first.collaborators.should_receive(:invite).with("john@doe.com").and_return(stub(:valid? => true, :email => "john@doe.com"))

      expect { subject.add }.to raise_error(SystemExit)
      Codeplane::CLI.stdout.should include("We sent an invitation to john@doe.com")
    end

    it "displays errors" do
      subject.args = ["repo", "john@doe.com"]
      subject.client.repositories.all.first.collaborators.should_receive(:invite).with("john@doe.com").and_return(stub(:valid? => false, :errors => ["Something is wrong"]))
      subject.should_receive(:exit).with(1).and_raise(SystemExit)

      expect { subject.add }.to raise_error(SystemExit)
      Codeplane::CLI.stderr.should include("* Something is wrong")
    end
  end

  describe "#remove" do
    let(:repo) { subject.client.repositories.all.first }

    it "displays message" do
      subject.args = ["repo", "john@doe.com"]
      repo.collaborators.should_receive(:remove).with("john@doe.com").and_return(stub(:success? => true))

      expect { subject.remove }.to raise_error(SystemExit)
      Codeplane::CLI.stdout.should include("We revoked john@doe.com permissions on 'repo'")
    end

    it "display errors" do
      subject.args = ["repo", "john@doe.com"]
      repo.collaborators.should_receive(:remove).with("john@doe.com").and_raise(Codeplane::NotFoundError)
      subject.should_receive(:exit).with(1).and_raise(SystemExit)

      expect { subject.remove }.to raise_error(SystemExit)
      Codeplane::CLI.stderr.should include("We couldn't find this collaborator")
    end
  end
end
