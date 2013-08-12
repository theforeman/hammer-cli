require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::Output::Definition do

  let(:definition) { HammerCLI::Output::Definition.new }
  let(:last_field) { definition.fields[-1] }
  let(:field_count) { definition.fields.length }
  let(:options) { {:opt1 => 1, :opt2 => 2} }

  it "should be able to add field" do
    definition.add_field :key, "label", options

    field_count.must_equal 1

    last_field.key.must_equal :key
    last_field.label.must_equal "label"
    last_field.options.must_equal options
  end

  it "append should allow to add data from another definition" do
    another_def = HammerCLI::Output::Definition.new
    another_def.add_field :a, "1"
    another_def.add_field :b, "2"

    definition.append another_def
    field_count.must_equal another_def.fields.length
    definition.fields.must_equal another_def.fields
  end

  context "path definition" do
    let(:path) { [:key1, :key2] }

    it "should save path to fields" do
      definition.add_field :key, "label", options.merge(:path => path)
      assert_equal options, last_field.options
    end

    it "should remove path from options" do
      definition.add_field :key, "label", options.merge(:path => path)
      last_field.path.must_equal path
    end

    it "should set path as empty array by default" do
      definition.add_field :key, "label"
      last_field.path.must_equal []
    end
  end

  context "formatters" do

    let(:formatter) { lambda() { "FORMATTER" } }

    it "should be able to add field with formatting function as a block" do
      definition.add_field :key, "label", &formatter

      assert_equal formatter, last_field.formatter
    end

    it "should store formatter for a field" do
      definition.add_field :key, "label", :formatter => formatter

      assert_equal formatter, last_field.formatter
      assert_equal nil, last_field.record_formatter
    end

    it "should store record formatter for a field" do
      definition.add_field :key, "label", :record_formatter => formatter

      assert_equal nil, last_field.formatter
      assert_equal formatter, last_field.record_formatter
    end

    it "should remove formatter from options" do
      definition.add_field :key, "label", options.merge(:formatter => formatter)
      assert_equal options, last_field.options
    end

    it "should remove record formatter from options" do
      definition.add_field :key, "label", options.merge(:record_formatter => formatter)
      assert_equal options, last_field.options
    end

  end

end

