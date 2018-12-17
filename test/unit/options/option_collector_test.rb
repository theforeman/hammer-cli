require_relative '../test_helper'

describe HammerCLI::Options::OptionCollector do
  before do
    @recognised_options = [mock('Option1'), mock('Option2')]
    @source1_result = {:option1 => 1, :option2 => nil, :option4 => HammerCLI::NilValue}
    @source2_result = @source1_result.merge({:option3 => 3})

    @source1 = mock('Source1')
    @source1.expects(:process).with(@recognised_options, {}).returns(@source1_result)

    @source2 = mock('Source2')
    @source2.expects(:process).with(@recognised_options, @source1_result).returns(@source2_result)

    @collector = HammerCLI::Options::OptionCollector.new(@recognised_options, [@source1, @source2])
  end

  describe '#options' do
    it 'returns options without nil values but with NIL values' do
      assert_equal({:option1 => 1, :option3 => 3, :option4 => nil}, @collector.options)
    end
  end

  describe '#all_options' do
    it 'returns all options' do
      assert_equal({:option1 => 1, :option2 => nil, :option3 => 3, :option4 => nil}, @collector.all_options)
    end
  end

  describe '#all_options_raw' do
    it 'returns all options with NIL values untranslated' do
      assert_equal({:option1 => 1, :option2 => nil, :option3 => 3, :option4 => HammerCLI::NilValue}, @collector.all_options_raw)
    end

    it 'can process validations' do
      validator = mock('Validator')
      validator.expects(:process).with(@recognised_options, @source1_result).returns(@source1_result)

      collector = HammerCLI::Options::OptionCollector.new(@recognised_options, [@source1, validator, @source2])

      assert_equal({:option1 => 1, :option2 => nil, :option3 => 3, :option4 => HammerCLI::NilValue}, collector.all_options_raw)
    end
  end
end
