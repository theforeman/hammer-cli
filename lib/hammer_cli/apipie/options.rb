module HammerCLI::Apipie
  module Options

    def self.included(base)
      base.extend(ClassMethods)
    end

    def all_method_options
      method_options_for_params(self.class.method_doc["params"], true)
    end

    def method_options
      method_options_for_params(self.class.method_doc["params"], false)
    end

    def method_options_for_params params, include_nil=true
      opts = {}
      params.each do |p|
        if p["expected_type"] == "hash"
          opts[p["name"]] = method_options_for_params(p["params"], include_nil)
        else
          opts[p["name"]] = send(p["name"]) rescue nil
        end
      end
      opts.reject! {|key, value| value.nil? } unless include_nil
      opts
    end

    module ClassMethods

      def apipie_options options={}
        raise "Specify apipie resource first." unless resource_defined?

        filter = options[:without] || []
        filter = [filter] unless filter.kind_of? Array

        options_for_params(method_doc["params"], filter)
      end

      protected

      def options_for_params params, filter
        params.each do |p|
          next if filter.include? p["name"]
          if p["expected_type"] == "hash"
            options_for_params(p["params"], filter)
          else
            create_option p
          end
        end
      end

      def create_option param
        option(
          option_switches(param),
          option_type(param),
          option_desc(param),
          option_opts(param),
          &option_formatter(param)
        )
      end

      def option_switches param
        '--' + param["name"].gsub('_', '-')
      end

      def option_type param
        param["name"].upcase.gsub('-', '_')
      end

      def option_desc param
        desc = param["description"].gsub(/<\/?[^>]+?>/, "")
        return " " if desc.empty?
        return desc
      end

      def option_opts param
        opts = {}
        opts[:required] = true if param["required"]
        return opts
      end

      def option_formatter param
        # FIXME: There is a bug in apipie, it does not produce correct expected type for Arrays
        # When it's fixed, we should test param["expected_type"] == "array"
        if param["validator"].include? "Array"
          lambda do |val|
            val.is_a?(String) ? val.split(",") : []
          end
        end
      end

    end
  end
end
