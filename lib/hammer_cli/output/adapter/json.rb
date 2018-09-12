module HammerCLI::Output::Adapter
  class Json < TreeStructure

    def print_record(fields, record)
      result = prepare_collection(fields, [record].flatten(1))
      output_stream.puts JSON.pretty_generate(result.first)
    end

    def print_collection(fields, collection)
      result = prepare_collection(fields, collection)
      output_stream.puts JSON.pretty_generate(result)
    end

    def print_message(msg, msg_params={})
      data = prepare_message(msg, msg_params)
      puts JSON.pretty_generate(data)
    end

  end

  HammerCLI::Output::Output.register_adapter(:json, Json)
end
