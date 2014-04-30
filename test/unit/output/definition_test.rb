require File.join(File.dirname(__FILE__), '../test_helper')



describe HammerCLI::Output::Definition do

  let(:definition) { HammerCLI::Output::Definition.new }
  let(:last_field) { definition.fields[-1] }
  let(:field_count) { definition.fields.length }

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

end

