
module HammerCLI

  class MainCommand < AbstractCommand

    option ["-v", "--verbose"], :flag, "be verbose"
    option ["-c", "--config"], "CFG_FILE", "path to custom config file"

    option ["-u", "--username"], "USERNAME", "username to access the remote system"
    option ["-p", "--password"], "PASSWORD", "password to access the remote system"

    option "--version", :flag, "show version" do
      puts "hammer-%s" % HammerCLI.version
      exit(0)
    end

    option "--autocomplete", "LINE", "Get list of possible endings" do |line|
      line = line.split
      line.shift
      endings = self.class.autocomplete(line).map { |l| l[0] }
      puts endings.join(' ')
      exit(0)
    end

    def password=(password)
      context[:password] = password.nil? ? ENV['FOREMAN_PASSWORD'] : password
    end

    def username=(username)
      context[:username] = username.nil? ? ENV['FOREMAN_USERNAME'] : username
    end

  end

end

# extend MainCommand
require 'hammer_cli/shell'

