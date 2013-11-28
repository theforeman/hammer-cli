require 'enumerator'

module HammerCLI

  class CompleterLine < Array

    def initialize(line)
      @line = line
      super(line.split)
    end

    def finished?
      (@line[-1,1] == " ") || @line.empty?
    end

  end

  class Completer

    def initialize(cmd_class)
      @command = cmd_class
    end


    def complete(line)
      line = CompleterLine.new(line)

      cmd, remaining = find_last_cmd(line)

      opt, value = option_to_complete(cmd, remaining)
      if opt
        return complete_attribute(opt, value)
      else
        param, value = param_to_complete(cmd, remaining)
        if param
          if remaining.finished?
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
        attribute.complete(value)
      else
        []
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

      if line.finished?
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

      if line.finished?
        # last word must be option and can't be flag -> we complete the value
        # "--option " nebo "--option xx "
        opt = cmd.find_option(line[-1])
        return [opt, nil] if opt and not opt.flag?
      else
        # we complete the value in the second case
        # "--opt" or "--option xx" or "xx yy"
        opt = cmd.find_option(line[-2])
        return [opt, line[-1]] if opt and not opt.flag?
      end
      return [nil, nil]
    end


    def find_last_cmd(line)
      cmd = @command
      subcommands = sub_command_map(cmd)

      cmd_idx = 0
      line.each_with_index do |word, idx|
        unless word.start_with?('-')
          break unless subcommands.has_key? word

          cmd = subcommands[word]
          cmd_idx = idx+1
          subcommands = sub_command_map(cmd)
        end
      end

      remaining = line.dup
      remaining.shift(cmd_idx) if cmd_idx > 0
      return [cmd, remaining]
    end


    def complete_command(command, remaining)
      completions = []
      completions += sub_command_names(command)
      completions += command_options(command)

      if remaining.finished?
        return completions
      else
        return filter(completions, remaining.last)
      end
    end


    def filter(completions, last_word)
      completions.select{|name| name.start_with? last_word }
    end


    def sub_command_map(cmd_class)
      cmd_class.recognised_subcommands.inject({}) do |cmd_map, cmd|
        cmd.names.each do |name|
          cmd_map.update(name => cmd.subcommand_class)
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
