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


  class ShellHistory

    def initialize(history_file_path)
      @file_path = history_file_path
      load
    end

    def push(line)
      line.strip!
      return if line.empty? or ingonred_commands.include?(line)

      Readline::HISTORY.push(line)
      File.open(file_path, "a") do |f|
        f.puts(line)
      end
    end

    def ingonred_commands
      ["exit"]
    end

    protected

    def file_path
      File.expand_path(@file_path)
    end

    def load
      if File.exist?(file_path)
        File.readlines(file_path).each do |line|
          Readline::HISTORY.push(line.strip)
        end
      end
    end

  end


  class ShellCommand < AbstractCommand

    DEFAULT_HISTORY_FILE = "~/.hammer_history"

    def execute
      ShellMainCommand.load_commands(HammerCLI::MainCommand)

      Readline.completion_append_character = ''
      Readline.completer_word_break_characters = ' '
      Readline.completion_proc = complete_proc

      stty_save = `stty -g`.chomp

      history = ShellHistory.new(Settings.get(:ui, :history_file) || DEFAULT_HISTORY_FILE)

      begin
        print_welcome_message

        while line = Readline.readline(prompt)

          history.push(line)

          ShellMainCommand.run('', line.split, context) unless line.start_with? 'shell' or line.strip.empty?
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
      print_message("Welcome to the hammer interactive shell")
      print_message("Type 'help' for usage information")
    end

    def common_prefix(results)
      results.delete_if{ |r| !r[0].start_with?(results[0][0][0]) }.length == results.length
    end

    def complete_proc
      completer = Completer.new(ShellMainCommand)
      Proc.new do |last_word|
        completer.complete(Readline.line_buffer)
      end
    end

  end

  HammerCLI::MainCommand.subcommand "shell", "Interactive shell", HammerCLI::ShellCommand
end
