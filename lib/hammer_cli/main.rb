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

    option ["--show-ids"], :flag, "Show ids of associated resources"

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

    def show_ids=(show_ids)
      context[:show_ids] = show_ids
    end

    def password=(password)
      context[:password] = password.nil? ? ENV['FOREMAN_PASSWORD'] : password
    end

    def username=(username)
      context[:username] = username.nil? ? ENV['FOREMAN_USERNAME'] : username
    end

    private

    def get_password(prompt="Enter Password ")
      ask(prompt) {|q| q.echo = false}
    end



  end

end

# extend MainCommand
require 'hammer_cli/shell'

