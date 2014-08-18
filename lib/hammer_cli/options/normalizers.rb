require 'json'

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

        def complete(val)
          []
        end
      end


      class KeyValueList < AbstractNormalizer

        def description
          _("Comma-separated list of key=value.")
        end

        def format(val)
          return {} unless val.is_a?(String)
          return {} if val.empty?

          result = {}

          pair_re = '([^,]+)=([^,\[]+|\[[^\[\]]*\])'
          full_re = "^((%s)[,]?)+$" % pair_re

          unless Regexp.new(full_re).match(val)
            raise ArgumentError, _("value must be defined as a comma-separated list of key=value")
          end

          val.scan(Regexp.new(pair_re)) do |key, value|
            value = value.strip
            value = value.scan(/[^,\[\]]+/) if value.start_with?('[')

            result[key.strip]=value
          end
          return result

        end
      end


      class List < AbstractNormalizer

        def description
          _("Comma separated list of values.")
        end

        def format(val)
          val.is_a?(String) ? val.split(",") : []
        end
      end


      class Bool < AbstractNormalizer

        def description
          _("One of true/false, yes/no, 1/0.")
        end

        def format(bool)
          bool = bool.to_s
          if bool.downcase.match(/^(true|t|yes|y|1)$/i)
            return true
          elsif bool.downcase.match(/^(false|f|no|n|0)$/i)
            return false
          else
            raise ArgumentError, _("value must be one of true/false, yes/no, 1/0")
          end
        end

        def complete(value)
          ["yes ", "no "]
        end
      end


      class File < AbstractNormalizer

        def format(path)
          ::File.read(::File.expand_path(path))
        end

        def complete(value)
          Dir[value.to_s+'*'].collect do |file|
            if ::File.directory?(file)
              file+'/'
            else
              file+' '
            end
          end
        end
      end

      class JSONInput < File

        def format(val)
          # The JSON input can be either the path to a file whose contents are
          # JSON or a JSON string.  For example:
          #   /my/path/to/file.json
          # or
          #   '{ "units":[ { "name":"zip", "version":"9.0", "inclusion":"false" } ] }')
          json_string = ::File.exist?(::File.expand_path(val)) ? super(val) : val
          ::JSON.parse(json_string)

        rescue ::JSON::ParserError => e
          raise ArgumentError, _("Unable to parse JSON input")
        end

      end


      class Enum < AbstractNormalizer

        def initialize(allowed_values)
          @allowed_values = allowed_values
        end

        def description
          _("One of %s") % quoted_values
        end

        def format(value)
          if @allowed_values.include? value
            value
          else
            raise ArgumentError, _("value must be one of '%s'") % quoted_values
          end
        end

        def complete(value)
          Completer::finalize_completions(@allowed_values)
        end

        private

        def quoted_values
          @allowed_values.map { |v| "'#{v}'" }.join(', ')
        end
      end


      class DateTime < AbstractNormalizer

        def description
          _("Date and time in YYYY-MM-DD HH:MM:SS or ISO 8601 format")
        end

        def format(date)
          raise ArgumentError unless date
          ::DateTime.parse(date).to_s
        rescue ArgumentError
          raise ArgumentError, _("'%s' is not a valid date") % date
        end
      end

      class EnumList < AbstractNormalizer

        def initialize(allowed_values)
          @allowed_values = allowed_values
        end

        def description
          _("Any combination (comma separated list) of '%s'") % quoted_values
        end

        def format(value)
          value.is_a?(String) ? parse(value) : []
        end

        def complete(value)
          Completer::finalize_completions(@allowed_values)
        end

        private

        def quoted_values
          @allowed_values.map { |v| "'#{v}'" }.join(', ')
        end

        def parse(arr)
          arr.split(",").uniq.tap do |values|
            unless values.inject(true) { |acc, cur| acc & (@allowed_values.include? cur) }
              raise ArgumentError, _("value must be a combination of '%s'") % quoted_values
            end
          end
        end
      end
    end
  end
end
