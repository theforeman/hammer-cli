module HammerCLI::Output::Adapter
  class Yaml < TreeStructure

    def print_record(fields, record)
      result = prepare_collection(fields, [record].flatten(1))
      puts YAML.dump(result.first)
    end

    def print_collection(fields, collection)
      result = prepare_collection(fields, collection)
      puts YAML.dump(result)
    end

  end
  HammerCLI::Output::Output.register_adapter(:yaml, Yaml)
end
