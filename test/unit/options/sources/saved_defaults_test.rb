require_relative '../../test_helper'

describe HammerCLI::Options::Sources::SavedDefaults do
  before do
    @defaults = mock
    @logger = stub
    @logger.stubs(:info)

    @defined_options = [
      stub(:attribute_name => :different_attr_name, :switches => ['--test']),
      stub(:attribute_name => :multiple_switches_option, :switches => ['--test-multi1', '--test-multi2'])
    ]

    @source = HammerCLI::Options::Sources::SavedDefaults.new(@defaults, @logger)
  end

  describe '#get_options' do
    it 'logs message about loaded default value' do
      @defaults.expects(:get_defaults).with('--test').returns(1)
      @defaults.expects(:get_defaults).with('--test-multi1').returns(:first_value)

      current_result = {}

      @logger.expects(:info).with('Custom default value 1 was used for attribute --test')
      @logger.expects(:info).with('Custom default value first_value was used for attribute --test-multi1')
      @source.get_options(@defined_options, current_result)
    end

    it 'reads values for all switches' do
      @defaults.expects(:get_defaults).with('--test').returns(1)
      @defaults.expects(:get_defaults).with('--test-multi1').returns(nil)
      @defaults.expects(:get_defaults).with('--test-multi2').returns(:second_value)

      current_result = {}
      expected_result = {
        :different_attr_name => 1,
        :multiple_switches_option => :second_value
      }

      assert_equal(expected_result, @source.get_options(@defined_options, current_result))
    end

    it 'keeps options that are already set' do
      @defaults.expects(:get_defaults).with('--test-multi1').returns(2)

      current_result = {:different_attr_name => :existing_value}
      expected_result = {
        :different_attr_name => :existing_value,
        :multiple_switches_option => 2
      }

      assert_equal(expected_result, @source.get_options(@defined_options, current_result))
    end
  end
end
