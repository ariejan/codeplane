module Codeplane
  module CLI
    class Repo < Base
      def self.help
        Codeplane::CLI.stdout.write <<-TEXT.strip_heredoc
          == Repository
             codeplane repo:list                    #{"# list all accessible repositories".gray}
             codeplane repo:add [NAME]              #{"# create a new repository called NAME".gray}
             codeplane repo:remove [NAME]           #{"# remove repository called NAME".gray}
             codeplane repo:info [NAME]             #{"# show info about matching repositories".gray}

        TEXT
      end

      def list
        repos = all
        larger = repos.collect {|r| r.name.size}.max

        Codeplane::CLI.stdout << repos.collect do |repo|
          padding = " " * (larger - repo.name.size)

          "".tap do |s|
            s << repo.name
            s << (repo.mine? ? " " : "*".yellow)
            s << padding << "    "
            s << "# #{repo.uri}".gray
          end
        end.join("\n") << "\n"
      end

      def add
        repo = client.repositories.create(:name => args.first)
        say_and_exit("Your Git url is #{repo.uri}\nGive it some time before cloning it.".green) if repo.valid?
        say_and_exit(bullets(repo.errors).red, 1)
      end

      def remove
        repo = find

        say_and_exit("You can't remove '#{repo.name}' because you don't own it".red, 1) unless repo.mine?

        if confirmed?
          repo.destroy
          say_and_exit("The repository '#{repo.name}' has been removed".green)
        end
      end

      def info
        say_and_exit("Provide the repository name".red, 1) if args.first.blank?
        repos = all.select {|repo| repo.name == args.first}
        say_and_exit("Couldn't find repository '#{args.first}'", 1) if repos.empty?

        output = ""

        repos.each do |repo|
          owner = repo.mine? ? "You" : "#{repo.user.name} (#{repo.user.email})"

          output.tap do |s|
            s << "Name: #{repo.name}\n"
            s << "Git url: #{repo.uri}\n"
            s << "Usage: #{human_size(repo.usage)}\n"
            s << "Owner: #{owner}\n\n"
          end
        end

        say_and_exit(output)
      end

      alias_method :base, :list

      private
      def find
        say_and_exit("Provide the repository name".red, 1) if args.first.blank?
        repo = all.find {|repo| repo.name == args.first}
        say_and_exit("Couldn't find '#{args.first}' repository".red, 1) unless repo
        repo
      end

      def all
        repos = client.repositories.all
        say_and_exit("No repositories found", 1) if repos.empty?
        repos
      end
    end
  end
end