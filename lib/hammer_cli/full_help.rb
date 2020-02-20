require 'hammer_cli/abstract'

module HammerCLI
  class FullHelpCommand < HammerCLI::AbstractCommand
    option "--md", :flag, _("Format output in markdown")

    def execute
      @adapter = option_md? ? MDAdapter.new : TxtAdapter.new
      HammerCLI.context[:full_help] = true
      print_heading
      print_help
      HammerCLI.context[:full_help] = false
      HammerCLI::EX_OK
    end

    private

    def print_heading
      @adapter.print_heading(_('Hammer CLI help'))
      @adapter.print_toc(HammerCLI::MainCommand)
    end

    def print_help(name='hammer', command=HammerCLI::MainCommand, desc='')
      @adapter.print_command(name, desc, command.new(name).help)

      command.recognised_subcommands.each do |sub_cmd|
        print_help(@adapter.command_name(name, sub_cmd.names.first), sub_cmd.subcommand_class, sub_cmd.description)
      end
    end

    class MDAdapter
      def command_name(parent, command_name)
        "#{parent} #{command_name}"
      end

      def print_command(name, description, help)
        print_heading(name, name.split.length)
        puts description
        puts
        puts "```"
        puts help
        puts "```"
        puts
      end

      def print_toc(cmd)
        names = cmd.recognised_subcommands.collect do |sub_cmd|
          sub_cmd.names[0]
        end
        names.sort.each do |name|
          puts "- [%s](#hammer-%s)" % [name, name.gsub(' ', '-')]
        end
        puts
      end

      def print_heading(text, level=1)
        puts '#'*level + ' ' + text
      end
    end

    class TxtAdapter
      def command_name(parent, command_name)
        "#{parent} > #{command_name}"
      end

      def print_command(name, description, help)
        print_heading(name, 2)
        puts description
        puts
        puts help
        puts
      end

      def print_toc(cmd)
      end

      def print_heading(text, level=1)
        ch = (level > 1) ? '-' : '='
        puts text
        puts ch * text.length
      end
    end
  end

  HammerCLI::MainCommand.subcommand "full-help", _("Print help for all hammer commands"), HammerCLI::FullHelpCommand
end
