require 'json'
require 'hammer_cli/csv_parser'

module HammerCLI
  module Options
    module Normalizers
      def self.available
        AbstractNormalizer.available
      end

      class AbstractNormalizer
        class << self
          attr_reader :available

          def inherited(subclass)
            @available ||= []
            @available << subclass
          end

          def completion_type
            :value
          end

          def common_description
            _("Value described in the option's description. Mostly simple string")
          end
        end

        def description
          ""
        end

        def format(val)
          raise NotImplementedError, "Class #{self.class.name} must implement method format."
        end

        def complete(val)
          []
        end

        def completion_type
          { type: self.class.completion_type }
        end
      end

      class Default < AbstractNormalizer
        def format(value)
          value
        end
      end

      class KeyValueList < AbstractNormalizer

        PAIR_RE = '([^,=]+)=([^,\{\[]+|[\{\[][^\{\}\[\]]*[\}\]])'
        FULL_RE = "^((%s)[,]?)+$" % PAIR_RE

        class << self
          def completion_type
            :key_value_list
          end

          def common_description
            _('Comma-separated list of key=value.') + "\n" +
              _('JSON is acceptable and preferred way for such parameters')
          end
        end

        def format(val)
          return {} unless val.is_a?(String)
          return {} if val.empty?

          if valid_key_value?(val)
            parse_key_value(val)
          else
            begin
              formatter = JSONInput.new
              formatter.format(val)
            rescue ArgumentError
              raise ArgumentError, _("Value must be defined as a comma-separated list of key=value or valid JSON.")
            end
          end
        end

        private

        def valid_key_value?(val)
          Regexp.new(FULL_RE).match(val)
        end

        def parse_key_value(val)
          result = {}
          val.scan(Regexp.new(PAIR_RE)) do |key, value|
            value = value.strip
            if value.start_with?('[')
              value = value.scan(/[^,\[\]]+/)
            elsif value.start_with?('{')
              value = parse_key_value(value[1...-1])
            end

            result[key.strip] = strip_value(value)
          end
          result
        end

        def strip_value(value)
          if value.is_a? Array
            value.map do |item|
              strip_chars(item.strip, '"\'')
            end
          elsif value.is_a? Hash
            value.map do |key, val|
              [strip_chars(key.strip, '"\''), strip_chars(val.strip, '"\'')]
            end.to_h
          else
            strip_chars(value.strip, '"\'')
          end
        end

        def strip_chars(string, chars)
          chars = Regexp.escape(chars)
          string.gsub(/\A[#{chars}]+|[#{chars}]+\z/, '')
        end
      end


      class List < AbstractNormalizer
        class << self
          def completion_type
            :list
          end

          def common_description
            _('Comma separated list of values. Values containing comma should be quoted or escaped with backslash.') +
              "\n" +
              _('JSON is acceptable and preferred way for such parameters')
          end
        end

        def format(val)
          return [] unless val.is_a?(String) && !val.empty?
          begin
            [JSON.parse(val)].flatten(1)
          rescue JSON::ParserError
            HammerCLI::CSVParser.new.parse(val)
          end
        end
      end

      class ListNested < AbstractNormalizer
        class << self
          def completion_type
            :schema
          end

          def common_description
            _('Comma separated list of values defined by a schema.') +
              "\n" +
              _('JSON is acceptable and preferred way for such parameters')
          end
        end

        class Schema < Array
          def description(richtext: true)
            '"' + reduce([]) do |schema, nested_param|
              name = nested_param.name
              name = HighLine.color(name, :bold) if nested_param.required? && richtext
              values = nested_param.validator.scan(/<[^>]+>[\w]+<\/?[^>]+>/)
              value_pattern = if values.empty?
                                "<#{nested_param.expected_type.downcase}>"
                              else
                                values = values.map do |value|
                                  value.gsub(/(<\/?[^>]+>)*([\.,]*)*/, '')
                                end
                                "[#{values.join('|')}]"
                              end
              schema << "#{name}=#{value_pattern}"
            end.join('\,').concat(', ... "')
          end
        end

        attr_reader :schema

        def initialize(schema)
          @schema = Schema.new(schema)
        end

        def format(val)
          return [] unless val.is_a?(String) && !val.empty?
          begin
            JSON.parse(val)
          rescue JSON::ParserError
            HammerCLI::CSVParser.new.parse(val).inject([]) do |results, item|
              next if item.empty?

              results << KeyValueList.new.format(item)
            end
          end
        end

        def completion_type
          super.merge({ schema: schema.description(richtext: false) })
        end
      end

      class Number < AbstractNormalizer
        class << self
          def completion_type
            :number
          end

          def common_description
            _('Numeric value. Integer')
          end
        end

        def format(val)
          if numeric?(val)
            val.to_i
          else
            raise ArgumentError, _("Numeric value is required.")
          end
        end

        def numeric?(val)
          Integer(val) != nil rescue false
        end
      end


      class Bool < AbstractNormalizer
        class << self
          def completion_type
            :boolean
          end

          def common_description
            _('One of %s') % ['true/false', 'yes/no', '1/0'].join(', ')
          end
        end

        def allowed_values
          ['yes', 'no', 'true', 'false', '1', '0']
        end

        def format(bool)
          bool = bool.to_s
          if bool.downcase.match(/^(true|t|yes|y|1)$/i)
            return true
          elsif bool.downcase.match(/^(false|f|no|n|0)$/i)
            return false
          else
            raise ArgumentError, _('Value must be one of %s.') % ['true/false', 'yes/no', '1/0'].join(', ')
          end
        end

        def complete(value)
          allowed_values.map { |v| v + ' ' }
        end

        def completion_type
          super.merge({ values: allowed_values })
        end
      end


      class File < AbstractNormalizer
        class << self
          def completion_type
            :file
          end

          def common_description
            _('Path to a file')
          end
        end

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
          raise ArgumentError, _("Unable to parse JSON input.")
        end

      end


      class Enum < AbstractNormalizer
        class << self
          def completion_type
            :enum
          end

          def common_description
            _("Possible values are described in the option's description")
          end
        end

        attr_reader :allowed_values

        def initialize(allowed_values)
          @allowed_values = allowed_values
        end

        def description
          _("Possible value(s): %s") % quoted_values
        end

        def format(value)
          if @allowed_values.include? value
            value
          else
            if allowed_values.count == 1
              msg = _("Value must be %s.") % quoted_values
            else
              msg = _("Value must be one of %s.") % quoted_values
            end
            raise ArgumentError, msg
          end
        end

        def complete(value)
          Completer::finalize_completions(@allowed_values)
        end

        def completion_type
          super.merge({ values: allowed_values })
        end

        private

        def quoted_values
          @allowed_values.map { |v| "'#{v}'" }.join(', ')
        end
      end


      class DateTime < AbstractNormalizer
        class << self
          def completion_type
            :datetime
          end

          def common_description
            _('Date and time in YYYY-MM-DD HH:MM:SS or ISO 8601 format')
          end
        end

        def format(date)
          raise ArgumentError unless date
          ::DateTime.parse(date).to_s
        rescue ArgumentError
          raise ArgumentError, _("'%s' is not a valid date.") % date
        end
      end

      class EnumList < AbstractNormalizer
        class << self
          def completion_type
            :multienum
          end

          def common_description
            _("Any combination of possible values described in the option's description")
          end
        end

        attr_reader :allowed_values

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

        def completion_type
          super.merge({ values: allowed_values })
        end

        private

        def quoted_values
          @allowed_values.map { |v| "'#{v}'" }.join(', ')
        end

        def parse(arr)
          arr.split(",").uniq.tap do |values|
            unless values.inject(true) { |acc, cur| acc & (@allowed_values.include? cur) }
              raise ArgumentError, _("Value must be a combination of '%s'.") % quoted_values
            end
          end
        end
      end
    end
  end
end
