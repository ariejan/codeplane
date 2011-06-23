module Codeplane
  module CLI
    autoload :Auth, "codeplane/cli/auth"
    autoload :Base, "codeplane/cli/base"
    autoload :Help, "codeplane/cli/help"
    autoload :Repo, "codeplane/cli/repo"
    autoload :Setup, "codeplane/cli/setup"
    autoload :Version, "codeplane/cli/version"
    autoload :User, "codeplane/cli/user"

    COMMANDS = %w[help version setup auth repo user]

    class << self
      attr_accessor :stdout, :stderr
    end

    def self.config_file
      @config_file ||= File.expand_path("~/.codeplane")
    end

    def self.start(argv = ARGV.dup, stdout = STDOUT, stderr = STDERR)
      @stdout, @stderr = stdout, stderr

      ARGV.delete_if { true }

      command, subcommand = argv.shift.to_s.split(":")
      command = "help" unless COMMANDS.include?(command)
      subcommand ||= "base"

      command_class = command_class_for(command)
      command_class.new(argv).run(subcommand)
    rescue SystemExit => error
      raise error
    rescue Codeplane::UnauthorizedError
      stderr << "\nWe couldn't authenticate you. Run `codeplane setup` to setup authentication or check your current authentication details in ~/.codeplane.\n".red
      exit(1)
    rescue Exception => error
      stderr << "\nSomething went wrong. Please try again!\n".red
      logger.error error.message
      exit(1)
    end

    def self.logger
      @logger ||= Logger.new(File.open(logger_file, "a+"))
    end

    def self.logger_file
      @logger_file ||= File.expand_path("~/.codeplane.log")
    end

    def self.command_class_for(command)
      Codeplane::CLI.const_get(command.camelize)
    end

    def self.credentials?
      credentials = YAML.load_file(config_file)
      Codeplane.username = credentials[:username]
      Codeplane.api_key = credentials[:api_key]
    rescue Exception
      false
    end
  end
end

at_exit { Codeplane::CLI.logger.close }
