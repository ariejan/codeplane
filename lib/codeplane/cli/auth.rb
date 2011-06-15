module Codeplane
  module CLI
    class Auth < Base
      def self.help
        Codeplane::CLI.stdout.write <<-TEXT.strip_heredoc
          == SSH public keys
             codeplane auth:list                    #{"# list all public keys".gray}
             codeplane auth:add [NAME] [FILE]       #{"# add public key located at FILE with the specified NAME".gray}
             codeplane auth:remove [NAME]           #{"# remove public key identified by NAME".gray}

        TEXT
      end

      def list
        keys = all
        larger = keys.collect {|r| r.name.size}.max

        Codeplane::CLI.stdout << keys.collect do |key|
          padding = " " * (larger - key.name.size)

          "".tap do |s|
            s << key.name
            s << "  #{padding}"
            s << "  # #{key.fingerprint}".gray
          end
        end.join("\n") << "\n"
      end

      def add
        say_and_exit("Provide both NAME and FILE parameters", 1) unless args.size == 2
        filepath = File.expand_path(args.last.to_s)
        say_and_exit("We couldn't find '#{args.last}' SSH public key file.", 1) unless File.file?(filepath)
        key = client.public_keys.create(:name => args.first, :key => File.read(filepath))
        say_and_exit("Your SSH public key '#{key.name}' was added".green) if key.valid?
        say_and_exit(bullets(key.errors).red, 1)
      end

      def remove
        key = find
        key.destroy
        say_and_exit("The SSH key '#{key.name}' has been removed".green)
      end

      alias_method :base, :list

      private
      def find
        say_and_exit("Provide the SSH key name", 1) if args.first.blank?
        key = all.find {|key| key.name == args.first}
        say_and_exit("Couldn't find '#{args.first}' key".red, 1) unless key
        key
      end

      def all
        keys = client.public_keys.all
        say_and_exit("No SSH keys were added", 1) if keys.empty?
        keys
      end
    end
  end
end
