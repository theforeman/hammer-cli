module HammerCLI
  module Options
    module Sources
      class SavedDefaults
        def initialize(defaults, logger)
          @defaults = defaults
          @logger = logger
        end

        def get_options(defined_options, result)
          if @defaults && @defaults.enabled?
            defined_options.each do |opt|
              result[opt.attribute_name] = add_custom_defaults(opt) if result[opt.attribute_name].nil?
            end
          end
          result
        end

        protected
        def add_custom_defaults(opt)
          opt.switches.each do |switch|
            value = @defaults.get_defaults(switch)
            if value
              @logger.info("Custom default value #{value} was used for attribute #{switch}")
              return value
            end
          end
          nil
        end
      end
    end
  end
end
