module Codeplane
  module CLI
    class Help < Base
      def self.help
        Codeplane::CLI.stdout.write <<-TEXT.strip_heredoc
          == Getting started

          Hi! Thanks for using Codeplane. Before you get started,
          you need to retrieve your API key.

          Just go to http://codeplane.com/account and check the "Integration"
          section. Then you can set up your credentials by running the
          following command:

            $ codeplane setup

          Inform your username and API key and you're ready to go!
          Your credentials will be saved at ~/.codeplane and chmod'ed as 0600.

          WARNING: Do not distribute these credentials or anyone will be able
          to manage your stuff, including destroying things. If you ever suspect
          that your API key is being used without your permission, go to
          http://codeplane.com/account and generate a new API key.

          If you're having a bad time, you can always contact us at team@codeplane.com.

          == Help
             codeplane help                         #{"# list complete help".gray}
             codeplane help [NAME]                  #{"# list help for specific command".gray}

        TEXT
      end

      def base
        commands_for_args.each do |command|
          command_class = Codeplane::CLI.command_class_for(command)
          command_class.help
        end
      rescue Exception
        self.class.help & exit(1)
      end

      def commands_for_args
        args.empty? ? Codeplane::CLI::COMMANDS : [args.first]
      end
    end
  end
end
