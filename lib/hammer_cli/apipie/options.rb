
module HammerCLI::Apipie
  module Options

    def self.included(base)
      base.extend(ClassMethods)
    end

    def all_method_options
      method_options_for_params(resource.action(action).params, true)
    end

    def method_options
      method_options_for_params(resource.action(action).params, false)
    end

    def method_options_for_params(params, include_nil=true)
      opts = {}
      params.each do |p|
        if p.expected_type == :hash
          opts[p.name] = method_options_for_params(p.params, include_nil)
        else
          opts[p.name] = get_option_value(p.name)
        end
      end
      opts.reject! {|key, value| value.nil? } unless include_nil
      opts
    end

    def get_option_value(opt_name)
      if respond_to?(HammerCLI.option_accessor_name(opt_name), true)
        send(HammerCLI.option_accessor_name(opt_name))
      else
        nil
      end
    end

    module ClassMethods

      def apipie_options(options={})
        setup_identifier_options
        if resource_defined?
          filter = options[:without] || []
          filter = Array(filter)
          filter += declared_identifiers.keys

          options_for_params(resource.action(action).params, filter)
        end
      end

      protected

      def options_for_params(params, filter)
        params.each do |p|
          next if filter.include?(p.name) || filter.include?(p.name.to_sym)
          if p.expected_type == :hash
            options_for_params(p.params, filter)
          else
            create_option p
          end
        end
      end

      def create_option(param)
        option(
          option_switches(param),
          option_type(param),
          option_desc(param),
          option_opts(param)
        )
      end

      def option_switches(param)
        '--' + param.name.gsub('_', '-')
      end

      def option_type(param)
        param.name.upcase.gsub('-', '_')
      end

      def option_desc(param)
        param.description || " "
      end

      def option_opts(param)
        opts = {}
        opts[:required] = true if param.required?
        # FIXME: There is a bug in apipie, it does not produce correct expected type for Arrays
        # When it's fixed, we should test param["expected_type"] == "array"
        opts[:format] = HammerCLI::Options::Normalizers::List.new if param.validator.include? "Array"
        return opts
      end

    end
  end
end
