module HammerCLI
  module Autocompletion

    def autocomplete(line, prefix=[])
      endings = []
      formated_prefix = prefix.join(' ')
      all_options = collect_all_options

      if line.length == 0 # look for possible next words
        endings = all_options.keys.map { |e| [e, formated_prefix]}
      elsif line.length == 1 && !all_options.key?(line[0]) # look for endings
        endings = all_options.select { |k,v| k if k.start_with? line[0] }.keys.map { |e| [e, formated_prefix]}
      else # dive into subcommands
        if all_options.key?(line[0]) && all_options[line[0]].class <= Clamp::Subcommand
          command = line.shift
          prefix << command
          endings = all_options[command].subcommand_class.autocomplete(line, prefix)
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
