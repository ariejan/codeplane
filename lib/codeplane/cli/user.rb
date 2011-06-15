module Codeplane
  module CLI
    class User < Base
      def self.help
        Codeplane::CLI.stdout.write <<-TEXT.strip_heredoc
          == User collaboration
             codeplane user:list [REPO]             #{"# list collaborators on given REPO".gray}
             codeplane user:add [REPO] [EMAIL]      #{"# invite EMAIL to join REPO".gray}
             codeplane user:remove [REPO] [EMAIL]   #{"# revoke permission for EMAIL on REPO".gray}

        TEXT
      end

      def list
        users = all
        larger = users.collect {|u| u.name.size}.max

        Codeplane::CLI.stdout << users.collect do |user|
          padding = " " * (larger - user.name.size)

          "".tap do |s|
            s << user.name
            s << padding << "    "
            s << "# #{user.email}".gray
          end
        end.join("\n") << "\n"
      end

      def add
        repo = find_repo
        invitation = repo.collaborators.invite(args.last)

        say_and_exit("We sent an invitation to #{invitation.email}".green) if invitation.valid?
        say_and_exit(bullets(invitation.errors).red, 1)
      end

      def remove
        repo = find_repo
        response = repo.collaborators.remove(args.last)

        say_and_exit("We revoked #{args.last} permissions on '#{repo.name}'".green) if response.success?
      rescue Codeplane::NotFoundError
        say_and_exit("We couldn't find this collaborator".red, 1)
      end

      alias_method :base, :list

      private
      def all
        repo = find_repo
        users = repo.collaborators.all
        say_and_exit("No collaborators were added to '#{repo.name}'", 1) if users.empty?
        users
      end

      def all_repos
        client.repositories.all
      end

      def find_repo
        say_and_exit("Provide the repository name".red, 1) if args.first.blank?
        repo = all_repos.find {|repo| repo.name == args.first && repo.mine?}
        say_and_exit("Couldn't find '#{args.first}' repository".red, 1) unless repo
        repo
      end
    end
  end
end
