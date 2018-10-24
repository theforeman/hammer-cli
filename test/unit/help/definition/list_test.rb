require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Help::List do
  describe '#build_string' do
    let(:first_item)  { [:first,   'This is first line'] }
    let(:second_item) { [:second,  'This is second line'] }
    let(:list) { HammerCLI::Help::List.new([first_item, second_item]) }

    it 'builds string' do
      list.build_string.must_equal [
        'first               This is first line',
        'second              This is second line',
        ''
      ].join("\n")
    end
  end
end
