require_relative '../test_helper'

describe HammerCLI::Options::OptionCollector do
  before do
    recognised_options = [mock, mock]
    source1_result = {:option1 => 1, :option2 => nil}
    source2_result = source1_result.merge({:option3 => 3})

    source1 = mock
    source1.expects(:get_options).with(recognised_options, {}).returns(source1_result)

    source2 = mock
    source2.expects(:get_options).with(recognised_options, source1_result).returns(source2_result)

    @collector = HammerCLI::Options::OptionCollector.new(recognised_options, [source1, source2])
  end

  describe '#options' do
    it 'returns options without nil values' do
      assert_equal({:option1 => 1, :option3 => 3}, @collector.options)
    end
  end

  describe '#all_options' do
    it 'returns all options' do
      assert_equal({:option1 => 1, :option2 => nil, :option3 => 3}, @collector.all_options)
    end
  end
end
