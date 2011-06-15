module Codeplane
  module CLI
    class Help < Base
      def self.help
        Codeplane::CLI.stdout.write <<-TEXT.strip_heredoc
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
