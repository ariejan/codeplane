module Codeplane
  module CLI
    class Version < Base
      def self.help
        Codeplane::CLI.stdout.write <<-TEXT.strip_heredoc
          == Version
             codeplane version                      #{"# display Codeplane's version".gray}

        TEXT
      end

      def base
        say_and_exit "Codeplane #{Codeplane::Version::STRING}"
      end
    end
  end
end
