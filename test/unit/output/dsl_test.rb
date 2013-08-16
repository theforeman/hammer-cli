require File.join(File.dirname(__FILE__), '../test_helper')


class CustomFieldType
  attr_reader :options

  def initialize(options)
    @options = options
  end
end

describe HammerCLI::Output::Dsl do

  let(:dsl) { HammerCLI::Output::Dsl.new }
  let(:field_type) { FieldType }
  let(:first_field) { dsl.fields[0] }
  let(:last_field) { dsl.fields[-1] }

  it "should be empty after initialization" do
    dsl.fields.length.must_equal 0
  end

  context "fields" do
    it "should create DataField as default field type" do
      dsl.build do
        field :f, "F"
      end
      first_field.class.must_equal HammerCLI::Output::DataField
    end

    it "should create DataField of desired type" do
      dsl.build do
        field :f, "F", CustomFieldType
      end
      first_field.class.must_equal CustomFieldType
    end

    it "should store all field details" do
      dsl.build do
        field :f, "F"
       end

      first_field.must_equal last_field
      first_field.path.must_equal [:f]
      first_field.label.must_equal "F"
    end

    it "can define multiple fields" do
      dsl.build do
        field :name, "Name"
        field :surname, "Surname"
        field :email, "Email"
      end

      dsl.fields.length.must_equal 3
    end
  end

  context "custom fields" do

    let(:options) {{:a => 1, :b => 2}}

    it "it creates field of a desired type" do
      dsl.build do
        custom_field CustomFieldType, :a => 1, :b => 2
      end
      first_field.class.must_equal CustomFieldType
    end

    it "passes all options to the field instance" do
      dsl.build do
        custom_field CustomFieldType, :a => 1, :b => 2
      end
      first_field.options.must_equal options
    end

  end

  context "path definition" do

    it "from appends to path" do
      dsl.build do
        from :key1 do
          field :email, "Email"
        end
      end
      last_field.path.must_equal [:key1, :email]
    end

    it "from can be nested" do
      dsl.build do
        from :key1 do
          from :key2 do
            from :key3 do
              field :name, "Name"
            end
            field :email, "Email"
          end
        end
      end
      first_field.path.must_equal [:key1, :key2, :key3, :name]
      last_field.path.must_equal [:key1, :key2, :email]
    end

  end



end

