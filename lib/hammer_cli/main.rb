require 'highline/import'

module HammerCLI

  class MainCommand < AbstractCommand

    option ["-v", "--verbose"], :flag, "be verbose"
    option ["-c", "--config"], "CFG_FILE", "path to custom config file"

    option ["-u", "--username"], "USERNAME", "username to access the remote system"
    option ["-p", "--password"], "PASSWORD", "password to access the remote system"

    option "--version", :flag, "show version" do
      puts "hammer-%s" % HammerCLI.version
      exit(HammerCLI::EX_OK)
    end

    option ["-P", "--ask-pass"], :flag, "Ask for password" do
      context[:password] = get_password()
      ''
    end

    option "--autocomplete", "LINE", "Get list of possible endings" do |line|
      line = line.split
      line.shift
      endings = self.class.autocomplete(line).map { |l| l[0] }
      puts endings.join(' ')
      exit(HammerCLI::EX_OK)
    end

    def run(*args)
      super
    end

    def password=(p)
      @password = p
      context[:password] = p
    end

    def username=(u)
      @username = u
      context[:username] = u
    end

    private

    def get_password(prompt="Enter Password ")
      ask(prompt) {|q| q.echo = false}
    end



  end

end

# extend MainCommand
require 'hammer_cli/shell'

