module HammerCLI
  module Testing
    module CommandAssertions
      class CommandExpectation
        include MiniTest::Assertions

        attr_accessor :expected_out, :expected_err, :expected_exit_code

        def initialize(expected_out="", expected_err="", expected_exit_code=0)
          @expected_out = expected_out
          @expected_err = expected_err
          @expected_exit_code = expected_exit_code
        end

        def assert_match(actual_result)
          assert_equal_or_match @expected_err, actual_result.err
          assert_equal_or_match @expected_out, actual_result.out
          assert_exit_code_equal @expected_exit_code, actual_result.exit_code
        end
      end

      class CommandRunResult
        def initialize(out="", err="", exit_code=0)
          @out = out
          @err = err
          @exit_code = exit_code
        end
        attr_accessor :out, :err, :exit_code
      end

      def run_cmd(options, context={}, cmd_class=HammerCLI::MainCommand)
        result = CommandRunResult.new
        result.out, result.err = capture_io do
          result.exit_code = cmd_class.run('hammer', options, context)
        end
        result
      end

      def exit_code_map
        return @exit_code_map unless @exit_code_map.nil?

        hammer_exit_codes = HammerCLI.constants.select{|c| c.to_s.start_with?('EX_')}
        @exit_code_map = hammer_exit_codes.inject({}) do |code_map, code|
          code_map.update(HammerCLI.const_get(code) => code)
        end
      end

      def assert_exit_code_equal(expected_code, actual_code)
        expected_info = "#{exit_code_map[expected_code]} (#{expected_code})"
        actual_info = "#{exit_code_map[actual_code]} (#{actual_code})"

        msg = "The exit code was expected to be #{expected_info}, but it was #{actual_info}"
        assert(expected_code == actual_code, msg)
      end

      def assert_cmd(expectation, actual_result)
        expectation.assert_match(actual_result)
      end

      def assert_equal_or_match(expected, actual)
        case expected
        when String
          assert_equal(expected, actual)
        when MatcherBase
          expected.assert_match(actual)
        else
          msg = actual
          assert_match(expected, actual, msg)
        end
      end

      def usage_error(command, message, heading=nil)
        command = (['hammer'] + command).join(' ')
        if heading.nil?
          ["Error: #{message}",
           "",
           "See: '#{command} --help'",
           ""].join("\n")
        else
          ["#{heading}:",
           "  Error: #{message}",
           "  ",
           "  See: '#{command} --help'",
           ""].join("\n")
        end
      end

      def common_error(command, message, heading=nil)
        command = (['hammer'] + command).join(' ')
        if heading.nil?
          ["Error: #{message}",
           ""].join("\n")
        else
          ["#{heading}:",
           "  Error: #{message}",
           ""].join("\n")
        end
      end

      def usage_error_result(command, message, heading=nil)
        expected_result = CommandExpectation.new
        expected_result.expected_err = usage_error(command, message, heading)
        expected_result.expected_exit_code = HammerCLI::EX_USAGE
        expected_result
      end

      def common_error_result(command, message, heading=nil)
        expected_result = CommandExpectation.new
        expected_result.expected_err = common_error(command, message, heading)
        expected_result.expected_exit_code = HammerCLI::EX_SOFTWARE
        expected_result
      end

      def success_result(message)
        CommandExpectation.new(message)
      end
    end
  end
end
