module HammerCLI::Output::Adapter
  class Json < TreeStructure

    def print_record(fields, record)
      result = prepare_collection(fields, [record].flatten(1))
      puts JSON.pretty_generate(result.first)
    end

    def print_collection(fields, collection)
      result = prepare_collection(fields, collection)
      puts JSON.pretty_generate(result)
    end

  end

  HammerCLI::Output::Output.register_adapter(:json, Json)
end
