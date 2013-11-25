module HammerCLI
  module Options
    module Normalizers


      class AbstractNormalizer
        def description
          ""
        end

        def format(val)
          raise NotImplementedError, "Class #{self.class.name} must implement method format."
        end
      end


      class KeyValueList < AbstractNormalizer

        def description
          "Comma-separated list of key=value."
        end

        def format(val)
          return {} unless val.is_a?(String)

          val.split(",").inject({}) do |result, item|
            parts = item.split("=")
            if parts.size != 2
              raise ArgumentError, "value must be defined as a comma-separated list of key=value"
            end
            result.update(parts[0] => parts[1])
          end
        end
      end


      class List < AbstractNormalizer

        def description
          "Comma separated list of values."
        end

        def format(val)
          val.is_a?(String) ? val.split(",") : []
        end
      end


      class Bool < AbstractNormalizer

        def description
          "One of true/false, yes/no, 1/0."
        end

        def format(bool)
          bool = bool.to_s
          if bool.downcase.match(/^(true|t|yes|y|1)$/i)
            return true
          elsif bool.downcase.match(/^(false|f|no|n|0)$/i)
            return false
          else
            raise ArgumentError, "value must be one of true/false, yes/no, 1/0"
          end
        end
      end


      class File < AbstractNormalizer

        def format(path)
          ::File.read(::File.expand_path(path))
        end
      end


      class Enum < AbstractNormalizer

        def initialize(allowed_values)
          @allowed_values = allowed_values
        end

        def description
          "One of %s" % quoted_values
        end

        def format(value)
          if @allowed_values.include? value
            value
          else
            raise ArgumentError, "value must be one of '%s'" % quoted_values
          end
        end

        private

        def quoted_values
          @allowed_values.map { |v| "'#{v}'" }.join(', ')
        end
      end

    end
  end
end
