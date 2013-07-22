require 'hammer_cli/abstract'
require 'readline'

module HammerCLI

  class ShellCommand < AbstractCommand

    def execute
      Readline.completion_append_character = " "
      Readline.completer_word_break_characters = ''
      Readline.completion_proc = complete_proc

      stty_save = `stty -g`.chomp

      begin
        while line = Readline.readline('hammer> ', true)
          HammerCLI::MainCommand.run('hammer', line.split) unless line.start_with? 'shell'
        end
      rescue Interrupt => e
        puts
        system('stty', stty_save) # Restore
        exit
      end
    end

    private

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

  HammerCLI::MainCommand.subcommand "shell", "Interactive Shell", HammerCLI::ShellCommand
end
