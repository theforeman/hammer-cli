module HammerCLI::Output::Adapter
  class Json < TreeStructure

    def print_record(fields, record)
      result = prepare_collection(fields, [record].flatten(1))
      output_stream.puts JSON.pretty_generate(result.first)
    end

    def print_collection(fields, collection, options = {})
      current_chunk = options[:current_chunk] || :single
      prepared = prepare_collection(fields, collection)
      result = JSON.pretty_generate(prepared)
      if current_chunk != :single
        result = if current_chunk == :first
                   result[0...-2] + ','
                 elsif current_chunk == :last
                   result[2..-1]
                 else
                   result[2...-2] + ','
                 end
      end
      output_stream.puts result
    end

    def print_message(msg, msg_params={})
      data = prepare_message(msg, msg_params)
      puts JSON.pretty_generate(data)
    end

  end

  HammerCLI::Output::Output.register_adapter(:json, Json)
end
