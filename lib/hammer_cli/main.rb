require 'highline/import'

module HammerCLI

  class MainCommand < AbstractCommand

    option ["-v", "--verbose"], :flag, _("be verbose"), :context_target => :verbose
    option ["-d", "--debug"], :flag, _("show debugging output "), :context_target => :debug
    option ["-r", "--reload-cache"], :flag, _("force reload of Apipie cache")

    option ["-c", "--config"], "CFG_FILE", _("path to custom config file")

    option ["-u", "--username"], "USERNAME", _("username to access the remote system"),
      :context_target => :username
    option ["-p", "--password"], "PASSWORD", _("password to access the remote system"),
      :context_target => :password
    option ["-s", "--server"], "SERVER", _("remote system address"),
      :context_target => :uri
    option ["--verify-ssl"], "VERIFY_SSL", _("Configure SSL verification of remote system"),
      :format => HammerCLI::Options::Normalizers::Bool.new
    option ["--ssl-ca-file"], "CA_FILE", _("Configure the file containing the CA certificates")
    option ["--ssl-ca-path"], "CA_PATH", _("Configure the directory containing the CA certificates")
    option ["--ssl-client-cert"], "CERT_FILE", _("Configure the client's public certificate")
    option ["--ssl-client-key"], "KEY_FILE", _("Configure the client's private key")
    option ["--ssl-with-basic-auth"], :flag, _("Use standard authentication in addition to client certificate authentication")
    option ["--fetch-ca-cert"], "SERVER", _("Fetch CA certificate from server and exit")

    option "--version", :flag, _("show version") do
      puts "hammer (%s)" % HammerCLI.version
      HammerCLI::Modules.names.each do |m|
        module_version = HammerCLI::Modules.find_by_name(m).version rescue _("unknown version")
        puts " * #{m} (#{module_version})"
      end
      exit(HammerCLI::EX_OK)
    end

    option ["--show-ids"], :flag, _("Show ids of associated resources"),
      :context_target => :show_ids
    option ["--interactive"], "INTERACTIVE", _("Explicitly turn interactive mode on/off"),
      :format => HammerCLI::Options::Normalizers::Bool.new,
      :context_target => :interactive

    option ["--csv"], :flag, _("Output as CSV (same as --output=csv)")
    option ["--output"], "ADAPTER", _("Set output format. One of [%s]") %
      HammerCLI::Output::Output.adapters.keys.join(', '),
      :context_target => :adapter
    option ["--csv-separator"], "SEPARATOR", _("Character to separate the values"),
      :context_target => :csv_separator


    option "--autocomplete", "LINE", _("Get list of possible endings") do |line|
      # get rid of word 'hammer' on the line
      line = line.to_s.gsub(/^\S+/, '')

      completer = Completer.new(HammerCLI::MainCommand)
      puts completer.complete(line).join(" ")
      exit(HammerCLI::EX_OK)
    end

    def option_csv=(csv)
      context[:adapter] = :csv
    end

  end

end


