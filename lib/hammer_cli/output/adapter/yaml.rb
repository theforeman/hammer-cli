module HammerCLI::Output::Adapter
  class Yaml < TreeStructure

    def print_record(fields, record)
      result = prepare_collection(fields, [record].flatten(1))
      output_stream.puts YAML.dump(result.first)
    end

    def print_collection(fields, collection)
      result = prepare_collection(fields, collection)
      output_stream.puts YAML.dump(result)
    end

    def print_message(msg, msg_params={})
      data = prepare_message(msg, msg_params)
      puts YAML.dump(data)
    end

  end
  HammerCLI::Output::Output.register_adapter(:yaml, Yaml)
end
