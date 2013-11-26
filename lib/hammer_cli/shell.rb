require 'hammer_cli/abstract'
require 'readline'

module HammerCLI

  class ShellMainCommand < AbstractCommand

    class HelpCommand < AbstractCommand
      command_name "help"
      desc "Print help for commands"

      parameter "[COMMAND] ...", "command"

      def execute
        ShellMainCommand.run('', command_list << '-h')
        HammerCLI::EX_OK
      end
    end

    class ExitCommand < AbstractCommand
      command_name "exit"
      desc "Exit interactive shell"

      def execute
        exit HammerCLI::EX_OK
      end
    end

    def self.load_commands(main_cls)
      cmds = main_cls.recognised_subcommands.select do |sub_cmd|
        !(sub_cmd.subcommand_class <= HammerCLI::ShellCommand)
      end
      self.recognised_subcommands.push(*cmds)
    end

    autoload_subcommands
  end

  class ShellCommand < AbstractCommand

    def execute
      Readline.completion_append_character = " "
      Readline.completer_word_break_characters = ''
      Readline.completion_proc = complete_proc

      stty_save = `stty -g`.chomp

      begin
        print_welcome_message
        ShellMainCommand.load_commands(HammerCLI::MainCommand)
        while line = Readline.readline(prompt, true)
          ShellMainCommand.run('', line.split) unless line.start_with? 'shell' or line.strip.empty?
        end
      rescue Interrupt => e
        puts
        system('stty', stty_save) # Restore
        exit
      end
    end

    private

    def prompt
      'hammer> '
    end

    def print_welcome_message
      puts "Welcome to the hammer interactive shell"
      puts "Type 'help' for usage information"
    end

    def common_prefix(results)
      results.delete_if{ |r| !r[0].start_with?(results[0][0][0]) }.length == results.length
    end

    def complete_proc
      Proc.new do |cpl|
        res = HammerCLI::MainCommand.autocomplete(cpl.split)
        # if there is one result or if results have common prefix
        # readline tries to replace current input with results
        # thus we should join the results with the start of the line
        if res.length == 1 || common_prefix(res)
          res.map { |r| r.delete_if{ |e| e == '' }.reverse.join(' ') }
        else
          res.map{ |e| e[0] }
        end
      end
    end

  end

  HammerCLI::MainCommand.subcommand "shell", "Interactive shell", HammerCLI::ShellCommand
end
