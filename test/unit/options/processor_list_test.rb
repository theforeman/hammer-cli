require_relative '../test_helper'

describe HammerCLI::Options::ProcessorList do
  let(:processor1) { stub('Processor1', :name => 'P1') }
  let(:processor2) { stub('Processor2', :name => 'P2') }
  let(:processor3) { stub('Processor3', :name => 'P3') }
  let(:new_processor) { stub('NewProcessor', :name => 'NewP') }

  let(:pl) { HammerCLI::Options::ProcessorList.new([processor1, processor2, processor3], name: 'TheProcessor') }

  describe '#name' do
    it 'returns the given name' do
      assert_equal 'TheProcessor', pl.name
    end
  end

  describe '#insert_relative' do
    it 'appends' do
      pl.insert_relative(:append, nil, new_processor)
      assert_equal pl.map(&:name), ['P1', 'P2', 'P3', 'NewP']
    end

    it 'prepends' do
      pl.insert_relative(:prepend, nil, new_processor)
      assert_equal pl.map(&:name), ['NewP', 'P1', 'P2', 'P3']
    end

    it 'inserts after' do
      pl.insert_relative(:after, 'P2', new_processor)
      assert_equal pl.map(&:name), ['P1', 'P2', 'NewP', 'P3']
    end

    it 'inserts before' do
      pl.insert_relative(:before, 'P2', new_processor)
      assert_equal pl.map(&:name), ['P1', 'NewP', 'P2', 'P3']
    end

    it 'raises an exception when the processor was not found' do
      ex = assert_raises ArgumentError do
        pl.insert_relative(:before, 'Unknown', new_processor)
      end
      assert_equal "Option processor 'Unknown' not found", ex.message
    end
  end

  describe '#find_by_name' do
    it 'finds a processor' do
      assert_equal processor2, pl.find_by_name('P2')
    end

    it 'raises an exception when the processor was not found' do
      ex = assert_raises ArgumentError do
        pl.find_by_name('Unknown')
      end
      assert_equal "Option processor 'Unknown' not found", ex.message
    end
  end

  describe '#process' do
    it 'calls all processors' do
      defined_options = []
      pl[0].expects(:process).with(defined_options, { :initial => 0 }).returns({ :initial => 0, :p1 => 1 })
      pl[1].expects(:process).with(defined_options, { :initial => 0, :p1 => 1 }).returns({ :p2 => 2 })
      pl[2].expects(:process).with(defined_options, { :p2 => 2 }).returns({ :p3 => 3 })

      result = pl.process(defined_options, { :initial => 0 })
      assert_equal({ :p3 => 3 }, result)
    end
  end
end
