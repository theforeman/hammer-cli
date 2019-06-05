require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Output::FieldFilter do
  let(:fields) do
    [
      Fields::Field.new(:label => 'field', :hide_blank => true),
      Fields::Collection.new(:label => 'collection'),
      Fields::Id.new(:label => 'id', :sets => ['THIN'])
    ]
  end
  let(:container_fields) do
    fields + [
      Fields::ContainerField.new(:label => 'container') do
        field :first, 'first'
        field :second, 'second', Fields::ContainerField do
          field :nested, 'nested'
        end
      end
    ]
  end
  let(:field_labels) { fields.map(&:label).sort }

  it 'lets all fields go by default' do
    f = HammerCLI::Output::FieldFilter.new(fields)
    f.filtered_fields.map(&:label).sort.must_equal ['field', 'collection', 'id'].sort
  end

  it 'filters fields by class' do
    f = HammerCLI::Output::FieldFilter.new(fields, classes_filter: [Fields::Id])
    f.filter_by_classes.filtered_fields.map(&:label).sort.must_equal ['field', 'collection'].sort
  end

  it 'filters fields by superclass' do
    f = HammerCLI::Output::FieldFilter.new(fields, classes_filter: [Fields::ContainerField])
    f.filter_by_classes.filtered_fields.map(&:label).sort.must_equal ['field', 'id'].sort
  end

  it 'filters fields by sets' do
    f = HammerCLI::Output::FieldFilter.new(fields, sets_filter: ['THIN'])
    f.filter_by_sets.filtered_fields.map(&:label).must_equal ['id']
  end

  it 'filters fields by sets with labels' do
    f = HammerCLI::Output::FieldFilter.new(fields, sets_filter: ['THIN', 'field'])
    f.filter_by_sets.filtered_fields.map(&:label).sort.must_equal ['field', 'id'].sort
  end

  it 'filters by full labels' do
    f = HammerCLI::Output::FieldFilter.new(container_fields, sets_filter: ['container/first'])
    f.filter_by_sets.filtered_fields.map(&:label).must_equal ['container']
  end

  it 'allows chained filtering' do
    f = HammerCLI::Output::FieldFilter.new(fields, sets_filter: ['THIN'], classes_filter: [Fields::Id])
    f.filter_by_classes.filter_by_sets.filtered_fields.map(&:label).must_equal []
  end

  it 'filters fields by data' do
    f = HammerCLI::Output::FieldFilter.new(fields)
    f.filter_by_data(nil).filtered_fields.map(&:label).sort.must_equal ['id', 'collection'].sort
  end
end
