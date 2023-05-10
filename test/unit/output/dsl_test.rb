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
    _(dsl.fields.length).must_equal 0
  end

  describe "fields" do
    it "should create Field as default field type" do
      dsl.build do
        field :f, "F"
      end
      _(first_field.class).must_equal Fields::Field
    end

    it "should create field of desired type" do
      dsl.build do
        field :f, "F", CustomFieldType
      end
      _(first_field.class).must_equal CustomFieldType
    end

    it "should store all field details" do
      dsl.build do
        field :f, "F"
       end

      _(first_field).must_equal last_field
      _(first_field.path).must_equal [:f]
      _(first_field.label).must_equal "F"
    end

    it "can define multiple fields" do
      dsl.build do
        field :name, "Name"
        field :surname, "Surname"
        field :email, "Email"
      end

      _(dsl.fields.length).must_equal 3
    end
  end

  describe "custom fields" do

    let(:options) {{:a => 1, :b => 2}}

    it "it creates field of a desired type" do
      dsl.build do
        custom_field CustomFieldType, :a => 1, :b => 2
      end
      _(first_field.class).must_equal CustomFieldType
    end

    it "passes all options to the field instance" do
      dsl.build do
        custom_field CustomFieldType, :a => 1, :b => 2
      end
      _(first_field.options).must_equal options
    end

  end

  describe "path definition" do

    it "from appends to path" do
      dsl.build do
        from :key1 do
          field :email, "Email"
        end
      end
      _(last_field.path).must_equal [:key1, :email]
    end

    it "path can be nil to handle the parent structure" do
      dsl.build do
        from :key1 do
          field nil, "Email"
        end
      end
      _(last_field.path).must_equal [:key1]
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
      _(first_field.path).must_equal [:key1, :key2, :key3, :name]
      _(last_field.path).must_equal [:key1, :key2, :email]
    end

  end


  describe "label" do

    it "creates field of type Label" do
      dsl.build do
        label "Label"
      end
      _(first_field.class).must_equal Fields::Label
    end

    it "allows to define subfields with dsl" do
      dsl.build do
        label "Label" do
          field :a, "A"
          field :b, "B"
        end
      end

      _(first_field.fields.map(&:label)).must_equal ["A", "B"]
    end

    it "sets correct path to subfields" do
      dsl.build do
        from :nest do
          label "Label" do
            field :a, "A"
            field :b, "B"
          end
        end
      end

      _(first_field.fields.map(&:path)).must_equal [[:a], [:b]]
    end

  end


  describe "collection" do

    it "creates field of type Collection" do
      dsl.build do
        collection :f, "F"
      end
      _(first_field.class).must_equal Fields::Collection
    end

    it "allows to define subfields with dsl" do
      dsl.build do
        collection :nest, "Label" do
          field :a, "A"
          field :b, "B"
        end
      end

      _(first_field.fields.map(&:label)).must_equal ["A", "B"]
    end

    it "sets correct path to subfields" do
      dsl.build do
        collection :nest, "Label" do
          field :a, "A"
          field :b, "B"
        end
      end

      _(first_field.fields.map(&:path)).must_equal [[:a], [:b]]
    end

  end

end

