require File.join(File.dirname(__FILE__), '../test_helper')



describe HammerCLI::Output::Definition do

  let(:definition) { HammerCLI::Output::Definition.new }
  let(:last_field) { definition.fields[-1] }
  let(:field_count) { definition.fields.length }
  let(:new_field) { Fields::Field.new(label: 'newfield', id: :new_id) }
  let(:label_field) { Fields::Label.new(label: 'labelfield') }
  let(:cont_field) { Fields::ContainerField.new(id: :id1) }


  describe "empty?" do

    it "returns true for empty definition" do
      definition.empty?.must_equal true
    end

    it "returns false for definition with fields" do
      definition.fields << Fields::Field.new
      definition.empty?.must_equal false
    end

  end

  it "should be able to add field" do
    definition.fields << Fields::Field.new
    field_count.must_equal 1
  end

  it "append should allow to add data from another definition" do
    another_def = HammerCLI::Output::Definition.new
    another_def.fields << Fields::Field.new
    another_def.fields << Fields::Field.new

    definition.append another_def.fields
    field_count.must_equal another_def.fields.length
    definition.fields.must_equal another_def.fields
  end

  it 'clear should delete all fields' do
    definition.fields << Fields::Field.new
    definition.clear
    definition.empty?.must_equal true
  end

  describe 'insert' do
    let(:new_fields) { [new_field, new_field] }

    describe 'before' do
      it 'should not insert field if output definition is empty' do
        definition.clear
        assert_raises ArgumentError do
          definition.insert(:before, :id1, new_field)
        end

        field_count.must_equal 0
      end

      it 'should insert new specified field before the old one' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:before, :id1, new_field)

        definition.fields.first.label.must_equal new_field.label
        field_count.must_equal 2
      end

      it 'should insert before field with few new specified' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:before, :id1, new_fields)

        definition.fields.first.label.must_equal new_field.label
        field_count.must_equal 3
      end

      it 'should accept block with new fields' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:before, :id1) do
          field nil, 'newfield'
          field nil, 'newfield2'
        end

        definition.fields.first.label.must_equal new_field.label
        field_count.must_equal 3
      end

      it 'should accept both block and new fields' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:before, :id1, new_fields) do
          field nil, 'newfield3'
          field nil, 'newfield4'
        end

        definition.fields.first.label.must_equal new_field.label
        field_count.must_equal 5
      end

      it 'should work with labels' do
        label_field.output_definition.fields << new_field
        definition.fields << label_field
        definition.insert(:before, label_field.label, new_fields)

        definition.fields.first.label.must_equal new_field.label
        field_count.must_equal 3
      end
    end

    describe 'after' do
      it 'should not insert field if output definition is empty' do
        definition.clear
        assert_raises ArgumentError do
          definition.insert(:after, :id1, new_field)
        end

        field_count.must_equal 0
      end

      it 'should insert new specified field after the old one' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:after, :id1, new_field)

        definition.fields.first.label.must_equal 'oldfield'
        field_count.must_equal 2
      end

      it 'should insert after field with few new specified' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:after, :id1, new_fields)

        definition.fields.first.label.must_equal 'oldfield'
        field_count.must_equal 3
      end

      it 'should accept block with new fields' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:after, :id1) do
          field nil, 'newfield'
          field nil, 'newfield2'
        end

        definition.fields.first.label.must_equal 'oldfield'
        field_count.must_equal 3
      end

      it 'should accept both block and new fields' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:after, :id1, new_fields) do
          field nil, 'newfield3'
          field nil, 'newfield4'
        end

        definition.fields.first.label.must_equal 'oldfield'
        field_count.must_equal 5
      end

      it 'should work with labels' do
        label_field.output_definition.fields << new_field
        definition.fields << label_field
        definition.insert(:after, label_field.label, new_fields)

        definition.fields.first.label.must_equal label_field.label
        field_count.must_equal 3
      end
    end

    describe 'replace' do
      it 'should not replace field if output definition is empty' do
        definition.clear
        assert_raises ArgumentError do
          definition.insert(:replace, :id1, new_field)
        end

        field_count.must_equal 0
      end

      it 'should replace field with new specified' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:replace, :id1, new_field)

        definition.fields.first.label.must_equal new_field.label
        field_count.must_equal 1
      end

      it 'should replace field with few new specified' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:replace, :id1, new_fields)

        definition.fields.first.label.must_equal new_field.label
        field_count.must_equal 2
      end

      it 'should accept block with new fields' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:replace, :id1) do
          field nil, 'newfield'
          field nil, 'newfield2'
        end

        definition.fields.first.label.must_equal new_field.label
      end

      it 'should accept both block and new fields' do
        definition.fields << Fields::Field.new(id: :id1, label: 'oldfield')
        definition.insert(:replace, :id1, new_fields) do
          field nil, 'newfield3'
          field nil, 'newfield4'
        end

        field_count.must_equal 4
      end

      it 'should work with labels' do
        label_field.output_definition.fields << new_field
        definition.fields << label_field
        definition.insert(:replace, label_field.label, new_fields)

        field_count.must_equal 2
      end
    end
  end

  describe 'find_field' do
    it 'should find a field' do
      definition.fields += [new_field, label_field]
      definition.find_field(:new_id).must_equal new_field
    end

    it 'should find a field in field output definition' do
      definition.fields += [label_field, cont_field]
      nested_definition = definition.find_field(:id1).output_definition
      nested_definition.fields << new_field
      nested_definition.find_field(:new_id).must_equal new_field
    end
  end

  describe 'at' do
    it 'should return self if no specified path or empty' do
      definition.at.must_equal definition
      definition.at([]).must_equal definition
    end

    it 'should return output definition of specified field with path' do
      cont_field.output_definition.fields << new_field
      definition.fields << cont_field
      path = [cont_field.id]

      definition.at(path).must_equal cont_field.output_definition
    end

    it 'should work with labels' do
      label_field.output_definition.fields << new_field
      definition.fields << label_field
      path = ['labelfield']

      definition.at(path).must_equal label_field.output_definition
    end
  end

  describe 'sets_table' do
    it 'prints a table with fields and sets ' do
      cont_field = Fields::ContainerField.new(id: :id1, label: 'cf', sets: ['SET']) do
        field :a, 'abc', Fields::Field
        field :b, 'bca', Fields::Field
      end
      definition.fields += [new_field, cont_field]

      sets_table = "---------|-----|---------|----\n" \
                   "FIELDS   | ALL | DEFAULT | SET\n" \
                   "---------|-----|---------|----\n" \
                   "Newfield | x   | x       |    \n" \
                   "Cf/abc   |     |         | x  \n" \
                   "Cf/bca   |     |         | x  \n" \
                   "---------|-----|---------|----\n"

      definition.sets_table.must_equal sets_table
    end
  end
end
