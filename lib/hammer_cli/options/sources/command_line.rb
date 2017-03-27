module HammerCLI
  module Options
    module Sources
      class CommandLine
        def initialize(command)
          @command = command
        end

        def get_options(defined_options, result)
          defined_options.each do |opt|
            result[opt.attribute_name] ||= @command.send(opt.read_method)
          end
          result
        end
      end
    end
  end
end
