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

  describe '#find_item' do
    it 'finds an item' do
      help.text('Lorem ipsum', id: :lorem)
      help.text('Dolor sit amet', id: :dolor)
      help.find_item(:dolor).id.must_equal :dolor
    end

    it 'finds a nested item' do
      help.section('Heading') do |h|
        h.text('Lorem ipsum', id: :lorem)
        h.text('Dolor sit amet', id: :dolor)
      end
      help.at('Heading') do |h|
        h.find_item(:dolor).id.must_equal :dolor
      end
    end
  end

  describe '#insert' do
    describe 'before' do
      it 'should insert new help item before the old one' do
        help.text('old', id: :old)
        help.insert(:before, :old) do |h|
          h.text('new', id: :new)
        end
        help.definition.first.id.must_equal :new
        help.definition.count.must_equal 2
      end

      it 'should insert multiple items before old item' do
        help.text('old', id: :old)
        help.insert(:before, :old) do |h|
          h.text('new', id: :new)
          h.text('new2', id: :new2)
        end
        help.definition.first.id.must_equal :new
        help.definition.count.must_equal 3
      end

      it 'should work with labels' do
        help.section('section') do |h|
          h.text('text in section')
        end
        help.insert(:before, 'section') do |h|
          h.text('text before section', id: :before_section)
        end
        help.definition.first.id.must_equal :before_section
        help.definition.count.must_equal 2
      end
    end

    describe 'after' do
      it 'should insert new help item after the old one' do
        help.text('old', id: :old)
        help.insert(:after, :old) do |h|
          h.text('new', id: :new)
        end
        help.definition[0].id.must_equal :old
        help.definition[1].id.must_equal :new
        help.definition.count.must_equal 2
      end

      it 'should insert multiple items after old item' do
        help.text('old', id: :old)
        help.insert(:after, :old) do |h|
          h.text('new', id: :new)
          h.text('new2', id: :new2)
        end
        help.definition[0].id.must_equal :old
        help.definition[1].id.must_equal :new
        help.definition[2].id.must_equal :new2
        help.definition.count.must_equal 3
      end

      it 'should work with labels' do
        help.section('section') do |h|
          h.text('text in section')
        end
        help.insert(:after, 'section') do |h|
          h.text('text before section', id: :after_section)
        end
        help.definition[1].id.must_equal :after_section
        help.definition.count.must_equal 2
      end
    end

    describe 'replace' do
      it 'should replace the old help item with new one' do
        help.text('old', id: :old)
        help.insert(:replace, :old) do |h|
          h.text('new', id: :new)
        end
        help.definition.first.id.must_equal :new
        help.definition.count.must_equal 1
      end

      it 'should replace the old help item with new ones' do
        help.text('old', id: :old)
        help.insert(:replace, :old) do |h|
          h.text('new', id: :new)
          h.text('new2', id: :new2)
        end
        help.definition[0].id.must_equal :new
        help.definition[1].id.must_equal :new2
        help.definition.count.must_equal 2
      end

      it 'should work with labels' do
        help.section('section') do |h|
          h.text('text in section')
        end
        help.insert(:replace, 'section') do |h|
          h.text('text instead of section', id: :instead_of_section)
        end
        help.definition.first.id.must_equal :instead_of_section
        help.definition.count.must_equal 1
      end
    end
  end

  describe '#at' do
    it 'should return self if path is empty' do
      help.text('foo', id: :foo)
      help.at([]) do |h|
        h.definition.first.id.must_equal :foo
      end
      help.at do |h|
        h.definition.first.id.must_equal :foo
      end
    end

    it 'should return definition of specified help item with path' do
      help.section('first', id: :first_section) do |h|
        h.text('first text in the first section', id: :first_text1)
        h.text('second text in the first section', id: :secon_text1)
      end
      help.section('second', id: :second_section) do |h|
        h.text('first text in the second section', id: :first_text2)
        h.text('second text in the second section', id: :secon_text2)
      end
      help.at(:first_section) do |h|
        h.section('nested section', id: :nested_section) do |h|
          h.text('text in nested section', id: :nested_text)
        end
      end
      help.at([:first_section, :nested_section]) do |h|
        h.definition.first.id.must_equal :nested_text
      end
    end

    it 'should work with labels' do
      help.section('first') do |h|
        h.text('first text in the first section', id: :first_text1)
        h.text('second text in the first section', id: :secon_text1)
      end
      help.section('second') do |h|
        h.text('first text in the second section', id: :first_text2)
        h.text('second text in the second section', id: :secon_text2)
      end
      help.at('first') do |h|
        h.section('nested section') do |h|
          h.text('text in nested section', id: :nested_text)
        end
      end
      help.at(['first', 'nested section']) do |h|
        h.definition.first.id.must_equal :nested_text
      end
    end
  end
end
