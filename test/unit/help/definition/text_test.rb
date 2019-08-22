require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Help::Text do
  describe '#build_string' do
    let(:text) { HammerCLI::Help::Text.new('text') }

    it 'builds string' do
      text.build_string.must_equal 'text'
    end

    it 'ensures that options are used' do
      text = HammerCLI::Help::Text.new('text', richtext: true)
      text.build_string.must_equal HighLine.color('text', :bold)
    end
  end
end
