require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Help::List do
  describe '#build_string' do
    let(:first_item)  { [:first,   'This is first line'] }
    let(:second_item) { [:second,  'This is second line'] }
    let(:list) { HammerCLI::Help::List.new([first_item, second_item]) }
    let(:item_with_options) { [:third, 'This is bold item', { bold: true }] }

    it 'builds string' do
      _(list.build_string).must_equal [
        'first               This is first line',
        'second              This is second line',
        ''
      ].join("\n")
    end

    it 'ensures that item options are used' do
      list = HammerCLI::Help::List.new([first_item, second_item, item_with_options])
      changed_item = HighLine.color('third', :bold)
      _(list.build_string).must_equal [
        'first               This is first line',
        'second              This is second line',
        "#{changed_item}               This is bold item",
        ''
      ].join("\n")
    end
  end
end
