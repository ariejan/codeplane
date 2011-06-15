module Codeplane
  module CLI
    class Setup < Base
      def self.help
        Codeplane::CLI.stdout.write <<-TEXT.strip_heredoc
          == Credentials
             codeplane setup                        #{"# save your username and API key to ~/.codeplane".gray}

        TEXT
      end

      def base
        Codeplane::CLI.stdout << "Your username: "
        Codeplane.username = gets.chomp

        Codeplane::CLI.stdout << "Your API key: "
        Codeplane.api_key = gets.chomp

        Codeplane::Request.get("/auth")

        File.open(Codeplane::CLI.config_file, "w+") do |file|
          file.chmod(0600)

          file << {
            :username => Codeplane.username,
            :api_key => Codeplane.api_key
          }.to_yaml
        end

        Codeplane::CLI.stdout << "\nYour credentials were saved at ~/.codeplane and chmoded as 0600.\n".green
      end
    end
  end
end
