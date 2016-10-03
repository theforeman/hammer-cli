require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Help::TextBuilder do
  let(:help) { HammerCLI::Help::TextBuilder.new }

  describe '#text' do
    it 'prints text' do
      help.text('Lorem ipsum')
      help.string.must_equal "Lorem ipsum\n"
    end

    it 'prints multiple blocks with spaces' do
      help.text('Lorem ipsum')
      help.text('Dolor sit amet')
      help.string.must_equal [
        'Lorem ipsum',
        '',
        'Dolor sit amet',
        ''
      ].join("\n")
    end
  end

  describe '#section' do
    it 'prints section heading' do
      help.section('Heading')
      help.string.must_equal "Heading:\n\n"
    end

    it 'indents section content' do
      help.section('Heading') do |h|
        h.text('Lorem ipsum')
        h.text('Dolor sit amet')
      end
      help.string.must_equal [
        'Heading:',
        '  Lorem ipsum',
        '',
        '  Dolor sit amet',
        ''
      ].join("\n")
    end
  end

  describe '#list' do
    it 'prints empty list' do
      help.list([])
      help.string.must_equal ""
    end

    it 'prints single column list' do
      help.list([
        :a,
        :bb,
        :ccc
      ])
      help.string.must_equal [
        'a',
        'bb',
        'ccc',
        ''
      ].join("\n")
    end

    it 'prints two column list' do
      help.list([
        [:a,   'This is line A'],
        [:bb,  'This is line B'],
        [:ccc]
      ])
      help.string.must_equal [
        'a                   This is line A',
        'bb                  This is line B',
        'ccc',
        ''
      ].join("\n")
    end

    it 'handles multiple lines in the second column' do
      help.list([
        [:a,   "This is line A\nThis is line A part two"],
        [:bb,  'This is line B'],
        [:ccc, 'This is line C']
      ])
      help.string.must_equal [
        'a                   This is line A',
        '                    This is line A part two',
        'bb                  This is line B',
        'ccc                 This is line C',
        ''
      ].join("\n")
    end

    it 'can adjust indentation of the second column' do
      help.list([
        ['a',  'This is line A'],
        ['This line B is too long for the first column',   'This is line B'],
        ['ccc', 'This is line C']
      ])
      help.string.must_equal [
        'a                                             This is line A',
        'This line B is too long for the first column  This is line B',
        'ccc                                           This is line C',
        ''
      ].join("\n")
    end
  end

  describe '#indent' do
    let(:text) {
      [
        'A',
        'B',
        '',
        ' C'
      ].join("\n")
    }

    it 'indents text' do
      expected_result = [
        '  A',
        '  B',
        '',
        '   C'
      ].join("\n")
      help.indent(text).must_equal(expected_result)
    end

    it 'indents text with custom padding' do
      expected_result = [
        '**A',
        '**B',
        '**',
        '** C'
      ].join("\n")
      help.indent(text, '**').must_equal(expected_result)
    end
  end
end

