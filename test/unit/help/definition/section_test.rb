require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Help::Section do
  describe '#build_string' do
    let(:section)     { HammerCLI::Help::Section.new('section') }
    let(:first_text)  { HammerCLI::Help::Text.new('first') }
    let(:second_text) { HammerCLI::Help::Text.new('second') }

    it 'builds string without definition' do
      _(section.build_string).must_equal "section:\n\n"
    end

    it 'builds string with definition' do
      section.definition = HammerCLI::Help::Definition.new([first_text, second_text])
      expected_output =  [
        'section:',
        '  first',
        '',
        '  second',
        ''
      ].join("\n")
      _(section.build_string).must_equal expected_output
    end
  end
end
