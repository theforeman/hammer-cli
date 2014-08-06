require 'enumerator'


module HammerCLI

  # Single "word" on a command line to complete.
  # It contains trailing spaces to recognize whether the word is complete or not.
  # --param[ ]* or -flag[ ]* or ['"]?word['"]?[ ]*
  class CompleterWord < String

    def initialize(str)
      @original = str
      if quoted?
        str = str.gsub(/^['"]/, '').gsub(/['"]\s*$/, '')
      else
        str = str.strip
      end
      super(str)
    end

    def quoted?
      quote != ""
    end

    def quote
      @original.gsub(/^(['"]?)(.*)$/, '\1')
    end

    def complete?
      if quoted?
        @original.strip.gsub(/^['"].*['"][\s]*$/, '') == ""
      else
        @original[-1,1] == " "
      end
    end

  end


  # Array of command line words for completion.
  # Splits string line to "words" with trailing spaces.
  # --param[=]?[ ]* or -flag[ ]* or ['"]word['"]?[ ]*
  class CompleterLine < Array

    def initialize(line)
      @line = line
      super(split_line)
    end

    def complete?
      self.empty? || self.last.complete?
    end

    protected

    def split_line
      @line.scan(/-[\w\-]+=?[\s]*|["][^"]*["]?[\s]*|['][^']*[']?[\s]*|[^\s]+[\s]*/).collect do |word|
        CompleterWord.new(word.gsub(/=$/, ' '))
      end
    end

  end


  class Completer

    def initialize(cmd_class)
      @command = cmd_class
    end

    def complete(line)
      line = CompleterLine.new(line)

      # get the last command on the line
      cmd, remaining = find_last_cmd(line)

      opt, value = option_to_complete(cmd, remaining)
      if opt
        return complete_attribute(opt, value)
      else
        param, value = param_to_complete(cmd, remaining)
        if param
          if remaining.complete?
            return complete_attribute(param, value) + complete_command(cmd, remaining)
          else
            return complete_attribute(param, value)
          end
        else
          return complete_command(cmd, remaining)
        end

      end
    end


    protected

    def complete_attribute(attribute, value)
      if attribute.respond_to?(:complete)
        if value != nil and value.quoted?
          filter(attribute.complete(value), value).map do |completion|
            quote_value(completion, value.quote)
          end
        else
          filter(attribute.complete(value), value)
        end
      else
        []
      end
    end

    def quote_value(val, quotes)
      if val[-1,1] == ' '
        quotes + val.strip + quotes + ' '
      else
        quotes + val
      end
    end

    def param_to_complete(cmd, line)
      params = cmd.parameters.select do |p|
        (p.attribute_name != 'subcommand_name') and (p.attribute_name != 'subcommand_arguments')
      end

      return [nil, nil] if params.empty?

      # select param candidates
      param_candidates = []
      line.reverse.each do |word|
        break if word.start_with?('-')
        param_candidates.unshift(word)
      end

      param = nil

      if line.complete?
        # "--option " or "--option xx " or "xx "
        value = nil
        param_index = param_candidates.size
      else
        # "--opt" or "--option xx" or "xx yy"
        value = param_candidates.last
        param_index = param_candidates.size - 1
      end

      if param_index >= 0
        if params.size > param_index
          param = params[param_index]
        elsif params.last.multivalued?
          param = params.last
        end
      end

      return [param, value]
    end

    def option_to_complete(cmd, line)
      return [nil, nil] if line.empty?

      if line.complete?
        # last word must be option and can't be flag -> we complete the value
        # "--option " or "--option xx "
        opt = find_option(cmd, line[-1])
        return [opt, nil] if opt and not opt.flag?
      else
        # we complete the value in the second case
        # "--opt" or "--option xx" or "xx yy"
        opt = find_option(cmd, line[-2])
        return [opt, line[-1]] if opt and not opt.flag?
      end
      return [nil, nil]
    end

    def find_option(cmd, switch)
      cmd.find_option(switch) unless switch.nil?
    end

    def find_last_cmd(line)
      cmd = @command
      subcommands = sub_command_map(cmd)

      # if the last word is not complete we have to select it's parent
      # -> shorten the line
      words = line.dup
      words.pop unless line.complete?

      cmd_idx = 0
      words.each_with_index do |word, idx|
        unless word.start_with?('-')
          break unless subcommands.has_key? word

          cmd = subcommands[word].subcommand_class
          cmd_idx = idx+1
          subcommands = sub_command_map(cmd)
        end
      end

      # cut processed part of the line and return remaining
      remaining = line.dup
      remaining.shift(cmd_idx) if cmd_idx > 0
      return [cmd, remaining]
    end

    def complete_command(command, remaining)
      completions = []
      completions += sub_command_names(command)
      completions += command_options(command)
      completions = Completer::finalize_completions(completions)

      if remaining.complete?
        return completions
      else
        return filter(completions, remaining.last)
      end
    end

    def filter(completions, last_word)
      if last_word.to_s != ""
        completions.select{|name| name.start_with? last_word }
      else
        completions
      end
    end

    def self.finalize_completions(completions)
      completions.collect{|name| name+' ' }
    end

    def sub_command_map(cmd_class)
      cmd_class.recognised_subcommands.inject({}) do |cmd_map, cmd|
        cmd.names.each do |name|
          cmd_map.update(name => cmd)
        end
        cmd_map
      end
    end

    def sub_command_names(cmd_class)
      sub_command_map(cmd_class).keys.flatten
    end

    def command_options(cmd_class)
      cmd_class.recognised_options.inject([]) do |opt_switches, opt|
        opt_switches += opt.switches
      end
    end

  end
end
