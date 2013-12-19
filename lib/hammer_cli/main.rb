require 'highline/import'

module HammerCLI

  class MainCommand < AbstractCommand

    option ["-v", "--verbose"], :flag, "be verbose"
    option ["-c", "--config"], "CFG_FILE", "path to custom config file"

    option ["-u", "--username"], "USERNAME", "username to access the remote system",
      :context_target => :username
    option ["-p", "--password"], "PASSWORD", "password to access the remote system",
      :context_target => :password

    option "--version", :flag, "show version" do
      puts "hammer (%s)" % HammerCLI.version
      HammerCLI::Modules.names.each do |m|
        module_version = HammerCLI::Modules.find_by_name(m).version
        puts " * #{m} (#{module_version})"
      end
      exit(HammerCLI::EX_OK)
    end

    option ["--show-ids"], :flag, "Show ids of associated resources",
      :context_target => :show_ids
    option ["--interactive"], "INTERACTIVE", "Explicitly turn interactive mode on/off",
      :format => HammerCLI::Options::Normalizers::Bool.new,
      :context_target => :interactive

    option ["--csv"], :flag, "Output as CSV (same as --adapter=csv)"
    option ["--output"], "ADAPTER", "Set output format. One of [%s]" %
      HammerCLI::Output::Output.adapters.keys.join(', '),
      :context_target => :adapter
    option ["--csv-separator"], "SEPARATOR", "Character to separate the values",
      :context_target => :csv_separator


    option "--autocomplete", "LINE", "Get list of possible endings" do |line|
      # get rid of word 'hammer' on the line
      line = line.to_s.gsub(/^\S+/, '')

      completer = Completer.new(HammerCLI::MainCommand)
      puts completer.complete(line).join(" ")
      exit(HammerCLI::EX_OK)
    end

    def csv=(csv)
      context[:adapter] = :csv
    end

  end

end

# extend MainCommand
require 'hammer_cli/shell'

