require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Output::FieldFilter do

  let(:fields) { [
    Fields::Field.new(:label => "field"),
    Fields::Collection.new(:label => "collection"),
    Fields::Id.new(:label => "id")
  ] }
  let(:field_labels) { fields.map(&:label).sort }

  it "lets all fields go by default" do
    f = HammerCLI::Output::FieldFilter.new
    f.filter(fields).map(&:label).sort.must_equal ["field", "collection", "id"].sort
  end

  it "filters fields by class" do
    f = HammerCLI::Output::FieldFilter.new([Fields::Id])
    f.filter(fields).map(&:label).sort.must_equal ["field", "collection"].sort
  end

  it "filters fields by superclass" do
    f = HammerCLI::Output::FieldFilter.new([Fields::ContainerField])
    f.filter(fields).map(&:label).sort.must_equal ["field", "id"].sort
  end

end
