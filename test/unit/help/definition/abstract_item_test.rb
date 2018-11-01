require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Help::AbstractItem do
  describe '#indent' do
    let(:first_item) { HammerCLI::Help::Text.new('Lorem ipsum') }
    let(:second_item) { HammerCLI::Help::Text.new(' Dolor sit amet') }
    let(:sub_definition) { HammerCLI::Help::Definition.new([first_item, second_item]) }

    it 'indents text' do
      section = HammerCLI::Help::Section.new('Heading', sub_definition)
      expected_result = [
        'Heading:',
        '  Lorem ipsum',
        '',
        '   Dolor sit amet',
        ''
      ].join("\n")
      section.build_string.must_equal(expected_result)
    end

    it 'indents text with custom padding' do
      section = HammerCLI::Help::Section.new('Heading', sub_definition, indentation: '**')
      expected_result = [
        'Heading:',
        '**Lorem ipsum',
        '**',
        '** Dolor sit amet',
        ''
      ].join("\n")
      section.build_string.must_equal(expected_result)
    end
  end
end
