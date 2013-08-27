module HammerCLI
  module Autocompletion

    def autocomplete(line, prefix=[])
      endings = []
      formated_prefix = prefix.join(' ')

      if line.length == 0 # look for possible next words
        all_options = collect_all_options
        endings = all_options.keys.map { |e| [e, formated_prefix] }
      elsif line.length == 1 && !(find_subcommand(line[0]) || find_option(line[0])) # look for endings
        all_options = collect_all_options
        endings = all_options.select { |k,v| k if k.start_with? line[0] }.keys.map { |e| [e, formated_prefix] }
      else # dive into subcommands
        subcommand = find_subcommand line[0]
        if subcommand
          command = line.shift
          prefix << command
          endings = subcommand.subcommand_class.autocomplete(line, prefix)
        end
      end
      endings
    end

    def collect_all_options
      all_options = {}

      if has_subcommands?
        recognised_subcommands.each do |item|
          
          label, _ = item.help
          all_options[label] = item
        end
      end

      recognised_options.each do |item|
        label, _ = item.help
        label.split(',').each do |option|
          all_options[option.split[0]] = item
        end
      end

      all_options
    end
  end
end
