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

    def print_message(msg, msg_params={})
      id = msg_params["id"] || msg_params[:id]
      name = msg_params["name"] || msg_params[:name]

      data = {
        :message => msg.format(msg_params)
      }
      data[:id] = id unless id.nil?
      data[:name] = name unless name.nil?

      puts YAML.dump(data)
    end

  end
  HammerCLI::Output::Output.register_adapter(:yaml, Yaml)
end
