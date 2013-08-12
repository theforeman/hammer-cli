require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::Output::Dsl do

  let(:dsl) { Object.new.extend(HammerCLI::Output::Dsl) }

  it "sets output header" do
    header_msg = "TEST HEADER"
    dsl.heading(header_msg)
    dsl.output_heading.must_equal header_msg
  end

  context "output definition" do

    it "should be empty after initialization" do
      dsl.output_definition.fields.length.must_equal 0
    end

    it "output can append existing definition" do
      definition = HammerCLI::Output::Definition.new
      definition.add_field :name, "Name"
      definition.add_field :surname, "Surname"

      dsl.output(definition)
      dsl.output_definition.fields.length.must_equal definition.fields.length
    end

    context "own fields" do
      let(:formatter) { lambda() { "some format" } }
      let(:first_field) { dsl.output_definition.fields[0] }
      let(:last_field) { dsl.output_definition.fields[-1] }

      it "can define it's own fields" do
        dsl.field :email, "Email", &formatter

        last_field.key.must_equal :email
        last_field.label.must_equal "Email"
        last_field.record_formatter.must_equal nil
        assert_equal formatter, last_field.formatter
      end

      it "can define it's own abstract fields" do
        dsl.abstract_field :email, "Email", &formatter

        last_field.key.must_equal :email
        last_field.label.must_equal "Email"
        last_field.formatter.must_equal nil
        assert_equal formatter, last_field.record_formatter
      end

      it "can define multiple fields" do
        dsl.field :name, "Name"
        dsl.field :surname, "Surname"
        dsl.field :email, "Email"

        dsl.output_definition.fields.length.must_equal 3
      end

      context "path definition" do

        it "stores empty path by default" do
          dsl.abstract_field :email, "Email"
          last_field.path.must_equal []
        end

        it "from appends to path" do
          dsl.from :key1 do
            dsl.abstract_field :email, "Email"
          end
          last_field.path.must_equal [:key1]
        end

        it "from can be nested" do
          dsl.from :key1 do
            dsl.from :key2 do
              dsl.from :key3 do
                dsl.abstract_field :name, "Name"
              end
              dsl.abstract_field :email, "Email"
            end
          end
          first_field.path.must_equal [:key1, :key2, :key3]
          last_field.path.must_equal [:key1, :key2]
        end

      end

    end

  end

end

