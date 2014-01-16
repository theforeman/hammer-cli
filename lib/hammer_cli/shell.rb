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

    class AuthCommand < AbstractCommand
      command_name "auth"
      desc "User's cerdentials actions"

      class LogoutCommand < AbstractCommand
        command_name "logout"
        desc "Wipe your credentials"

        option '--service', 'SERVICE', "Service to log out from"

        def execute

          if option_service
            HammerCLI::Connection.clean_credentials(option_service)
          else
            HammerCLI::Connection.clean_all_credentials
          end
          HammerCLI::Connection.drop_all
          print_message("Credentials deleted.")
          HammerCLI::EX_OK
        end
      end

      class InfoCommand < AbstractCommand
        command_name "status"
        desc "Information about current connections"

        def execute
          if HammerCLI::Connection.credentials.keys.length > 0
            print_message("You are logged in:")
            HammerCLI::Connection.credentials.each do |service, creds|
              print_message("  - #{service} as [ #{creds[:username]} ]")
            end
          else
            print_message("You are currently not logged in to any service.\nUse the service to set credentials.")
          end
          HammerCLI::EX_OK
        end
      end

      autoload_subcommands
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
      ShellMainCommand.load_commands(HammerCLI::MainCommand)

      Readline.completion_append_character = ''
      Readline.completer_word_break_characters = ' '
      Readline.completion_proc = complete_proc

      stty_save = `stty -g`.chomp

      begin
        print_welcome_message
        while line = Readline.readline(prompt, true)
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
