
module HammerCLI::Apipie
  module Options

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

  end
end
