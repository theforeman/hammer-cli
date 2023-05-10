require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Help::Definition do
  let(:definition) { HammerCLI::Help::Definition.new }
  let(:old_text_item)  { HammerCLI::Help::Text.new('Lorem ipsum', id: :old) }
  let(:new_text_item)  { HammerCLI::Help::Text.new('Dolor sit amet', id: :new) }

  describe '#build_string' do
    describe 'text' do
      it 'prints text via definition' do
        definition << HammerCLI::Help::Text.new('Lorem ipsum')
        _(definition.build_string).must_equal "Lorem ipsum\n"
      end

      it 'prints multiple blocks with spaces via definition' do
        definition << HammerCLI::Help::Text.new('Lorem ipsum')
        definition << HammerCLI::Help::Text.new('Dolor sit amet')
        _(definition.build_string).must_equal [
          'Lorem ipsum',
          '',
          'Dolor sit amet',
          ''
        ].join("\n")
      end
    end

    describe 'section' do
      it 'prints section heading via definition' do
        definition << HammerCLI::Help::Section.new('Heading')
        _(definition.build_string).must_equal "Heading:\n\n"
      end

      it 'indents section content via definition' do
        sub_definition = HammerCLI::Help::Definition.new
        sub_definition << HammerCLI::Help::Text.new('Lorem ipsum')
        sub_definition << HammerCLI::Help::Text.new('Dolor sit amet')
        definition << HammerCLI::Help::Section.new('Heading', sub_definition)
        _(definition.build_string).must_equal [
          'Heading:',
          '  Lorem ipsum',
          '',
          '  Dolor sit amet',
          ''
        ].join("\n")
      end
    end

    describe 'list' do
      it 'prints empty list via definition' do
        builder = HammerCLI::Help::TextBuilder.new
        builder.list([])
        _(builder.definition.build_string).must_equal ''
      end

      it 'prints single column list' do
        definition << HammerCLI::Help::List.new([
          :a,
          :bb,
          :ccc
        ])
        _(definition.build_string).must_equal [
          'a',
          'bb',
          'ccc',
          ''
        ].join("\n")
      end

      it 'prints two column list via definition' do
        definition << HammerCLI::Help::List.new([
          [:a,   'This is line A'],
          [:bb,  'This is line B'],
          [:ccc]
        ])
        _(definition.build_string).must_equal [
          'a                   This is line A',
          'bb                  This is line B',
          'ccc',
          ''
        ].join("\n")
      end

      it 'handles multiple lines in the second column via definition' do
        definition << HammerCLI::Help::List.new([
          [:a,   "This is line A\nThis is line A part two"],
          [:bb,  'This is line B'],
          [:ccc, 'This is line C']
        ])
        _(definition.build_string).must_equal [
          'a                   This is line A',
          '                    This is line A part two',
          'bb                  This is line B',
          'ccc                 This is line C',
          ''
        ].join("\n")
      end

      it 'can adjust indentation of the second column via definition' do
        definition << HammerCLI::Help::List.new([
          ['a',  'This is line A'],
          ['This line B is too long for the first column',   'This is line B'],
          ['ccc', 'This is line C']
        ])
        _(definition.build_string).must_equal [
          'a                                             This is line A',
          'This line B is too long for the first column  This is line B',
          'ccc                                           This is line C',
          ''
        ].join("\n")
      end
    end
  end

  describe '#find_item' do
    it 'finds an item' do
      definition << old_text_item
      definition << new_text_item
      _(definition.find_item(:new)).must_equal new_text_item
    end
  end

  describe '#insert_definition' do
    let(:new_definition) { HammerCLI::Help::Definition.new([new_text_item, new_text_item]) }
    let(:section_item)   { HammerCLI::Help::Section.new('section', id: :section) }

    describe 'before' do
      it 'should insert new help item before the old one' do
        definition << old_text_item
        definition.insert_definition(:before, :old, new_text_item.definition)
        _(definition.first.id).must_equal new_text_item.id
        _(definition.count).must_equal 2
      end

      it 'should insert multiple items before old item' do
        definition << old_text_item
        definition.insert_definition(:before, :old, new_definition)
        _(definition.first.id).must_equal new_text_item.id
        _(definition.count).must_equal 3
      end

      it 'should work with labels' do
        definition << section_item
        definition.insert_definition(:before, 'section', new_definition)
        _(definition.first.id).must_equal new_text_item.id
        _(definition.count).must_equal 3
      end
    end

    describe 'after' do
      it 'should insert new help item after the old one' do
        definition << old_text_item
        definition.insert_definition(:after, :old, new_text_item.definition)
        _(definition[0].id).must_equal old_text_item.id
        _(definition[1].id).must_equal new_text_item.id
        _(definition.count).must_equal 2
      end

      it 'should insert multiple items after old item' do
        definition << old_text_item
        definition.insert_definition(:after, :old, new_definition)
        _(definition[0].id).must_equal old_text_item.id
        _(definition[1].id).must_equal new_text_item.id
        _(definition[2].id).must_equal new_text_item.id
        _(definition.count).must_equal 3
      end

      it 'should work with labels' do
        definition << section_item
        definition.insert_definition(:after, 'section', new_text_item.definition)
        _(definition[1].id).must_equal new_text_item.id
        _(definition.count).must_equal 2
      end
    end

    describe 'replace' do
      it 'should replace the old help item with new one' do
        definition << old_text_item
        definition.insert_definition(:replace, :old, new_text_item.definition)
        _(definition.first.id).must_equal new_text_item.id
        _(definition.count).must_equal 1
      end

      it 'should replace the old help item with new ones' do
        definition << old_text_item
        definition.insert_definition(:replace, :old, new_definition)
        _(definition[0].id).must_equal new_text_item.id
        _(definition[1].id).must_equal new_text_item.id
        _(definition.count).must_equal 2
      end

      it 'should work with labels' do
        definition << section_item
        definition.insert_definition(:replace, 'section', new_text_item.definition)
        _(definition.first.id).must_equal new_text_item.id
        _(definition.count).must_equal 1
      end
    end
  end

  describe '#at' do
    it 'should return self if path is empty' do
      definition << old_text_item
      definition.at([]) do |h|
        _(h.definition.first.id).must_equal old_text_item.id
      end
    end

    it 'should accept integer' do
      definition << old_text_item
      definition << new_text_item
      definition.at(1) do |h|
        _(h.definition.first.id).must_equal new_text_item.id
      end
    end

    it 'should return definition of specified help item with path' do
      sub_definition = HammerCLI::Help::Definition.new
      sub_definition << old_text_item
      sub_definition << new_text_item
      definition << HammerCLI::Help::Section.new('first', sub_definition, id: :first_section)
      definition << HammerCLI::Help::Section.new('second', sub_definition, id: :second_section)
      definition.at(:first_section).definition << HammerCLI::Help::Section.new('nested', sub_definition, id: :nested_section)
      _(definition.at([:first_section, :nested_section]).definition.first.id).must_equal old_text_item.id
    end

    it 'should work with labels' do
      sub_definition = HammerCLI::Help::Definition.new
      sub_definition << old_text_item
      sub_definition << new_text_item
      definition << HammerCLI::Help::Section.new('first', sub_definition)
      definition << HammerCLI::Help::Section.new('second', sub_definition)
      definition.at('first').definition << HammerCLI::Help::Section.new('nested', sub_definition)
      _(definition.at(['first', 'nested']).definition.first.id).must_equal old_text_item.id
    end
  end
end
