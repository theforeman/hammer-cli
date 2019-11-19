module HammerCLI::Output::Adapter
  class Yaml < TreeStructure

    def print_record(fields, record)
      result = prepare_collection(fields, [record].flatten(1))
      output_stream.puts YAML.dump(result.first)
    end

    def print_collection(fields, collection, options = {})
      current_chunk = options[:current_chunk] || :single
      prepared = prepare_collection(fields, collection)
      result = YAML.dump(prepared)
      result = result[4..-1] unless %i[first single].include?(current_chunk)
      output_stream.puts result
    end

    def print_message(msg, msg_params={})
      data = prepare_message(msg, msg_params)
      puts YAML.dump(data)
    end

  end
  HammerCLI::Output::Output.register_adapter(:yaml, Yaml)
end
