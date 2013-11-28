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
      desc "Login and logout actions"

      class LoginCommand < AbstractCommand
        command_name "login"
        desc "Set credentials"

        def execute
          context[:username] = ask_username
          context[:password] = ask_password
          HammerCLI::EX_OK
        end
      end

      class LogoutCommand < AbstractCommand
        command_name "logout"
        desc "Wipe your credentials"

        def execute
          context[:username] = nil
          context[:password] = nil

          if username(false)
            print_message("Credentials deleted, using defaults now.")
            print_message("You are logged in as [ %s ]." % username(false))
          else
            print_message("Credentials deleted.")
          end
          HammerCLI::EX_OK
        end
      end

      class InfoCommand < AbstractCommand
        command_name "status"
        desc "Information about current user"

        def execute
          if username(false)
            print_message("You are logged in as [ %s ]." % username(false))
          else
            print_message("You are currently not logged in.\nUse 'auth login' to set credentials.")
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

      Readline.completion_append_character = " "
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
