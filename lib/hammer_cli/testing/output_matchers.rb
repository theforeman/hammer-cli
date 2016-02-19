module HammerCLI
  module Testing
    module OutputMatchers
      class MatcherBase
        include MiniTest::Assertions

        def initialize(expected="")
          @expected = expected
        end

        def assert_match(actual)
          assert_equal(@expected, actual)
        end
      end

      class FieldMatcher < MatcherBase
        def initialize(label, value)
          @expected = FieldMatcher.matcher(label, value)
        end

        def assert_match(actual)
          message = "Regex /#{@expected.source}/ didn't match the output:\n#{actual}"
          assert(@expected =~ actual, message)
        end

        def self.matcher(label, value)
          Regexp.new(Regexp.quote(label) + ':[ ]+' + Regexp.quote(value))
        end
      end

      class OutputMatcher < MatcherBase
        attr_accessor :expected_lines

        def initialize(expected="", options={})
          @expected_lines = expected.is_a?(Array) ? expected : [expected]
          @ignore_whitespace = options.fetch(:ignore_whitespace, true)
        end

        def assert_match(actual)
          if @ignore_whitespace
            expected_lines = strip_lines(@expected_lines)
            actual = strip_lines(actual.split("\n")).join("\n")
          else
            expected_lines = @expected_lines
          end
          expected_lines = expected_lines.join("\n")

          message = "Output didn't contain expected lines:\n" + diff(expected_lines, actual)
          assert(actual.include?(expected_lines), message)
        end

        protected

        def strip_lines(lines)
          lines.map(&:rstrip)
        end
      end

      class IndexMatcher < MatcherBase
        def initialize(expected=[])
          @line_matchers = []
          expected.each do |line_expectation|
            @line_matchers << IndexLineMatcher.new(line_expectation)
          end
        end

        def assert_match(actual)
          @line_matchers.each do |matcher|
            matcher.assert_match(actual)
          end
        end
      end

      class IndexLineMatcher < MatcherBase
        def initialize(expected=[])
          @expected_values = expected
        end

        def assert_match(actual)
          message = [
            "Regex didn't match the output.",
            "Expected regex:",
            line_regexp.source,
            "Expected fields:",
            @expected_values.join(' | '),
            "Actual output:",
            actual
          ].join("\n")

          assert(line_regexp =~ actual, message)
        end

        protected

        def line_regexp
          re = @expected_values.map do |column|
            Regexp.quote(column)
          end.join('[ ]*\|[ ]*')
          Regexp.new("[ ]*#{re}[ ]*")
        end
      end

    end
  end
end
