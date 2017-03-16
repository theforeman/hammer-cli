require_relative '../../test_helper'

describe HammerCLI::Options::Sources::CommandLine do

  before do
    @cmd = mock

    @defined_options = [
      stub(:read_method => :option_organization_id, :attribute_name => :organization_id),
      stub(:read_method => :option_location_id, :attribute_name => :location_id)
    ]

    @source = HammerCLI::Options::Sources::CommandLine.new(@cmd)
  end

  describe '#get_options' do
    it 'reads options from the command' do
      @cmd.expects(:option_organization_id).returns(2)
      @cmd.expects(:option_location_id).returns(3)

      current_result = { :help => true }
      expected_result = { :help => true, :organization_id => 2, :location_id => 3 }

      assert_equal(expected_result, @source.get_options(@defined_options, current_result))
    end

    it 'keeps options that are already set' do
      @cmd.expects(:option_location_id).returns(3)

      current_result = { :help => true, :organization_id => 1 }
      expected_result = { :help => true, :organization_id => 1, :location_id => 3 }

      assert_equal(expected_result, @source.get_options(@defined_options, current_result))
    end
  end
end
