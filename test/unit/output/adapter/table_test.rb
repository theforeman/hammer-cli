require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Table do

  let(:adapter) { HammerCLI::Output::Adapter::Table.new }

  it "allows default pagination" do
    adapter.paginate_by_default?.must_equal true
  end

  context "print_collection" do

    let(:field_name) { Fields::Field.new(:path => [:fullname], :label => "Name") }
    let(:field_firstname) { Fields::Field.new(:path => [:firstname], :label => "Firstname") }
    let(:field_lastname) { Fields::Field.new(:path => [:lastname], :label => "Lastname") }
    let(:field_long) { Fields::Field.new(:path => [:long], :label => "Full") }

    let(:fields) {
      [field_name]
    }

    let(:record) { {
      :id => 1,
      :firstname => "John",
      :lastname => "Doe",
      :fullname => "John Doe",
      :long => "SomeVeryLongString"
    } }
    let(:data) { HammerCLI::Output::RecordCollection.new [record] }
    let(:empty_data) { HammerCLI::Output::RecordCollection.new [] }

    it "should print column name " do
      proc { adapter.print_collection(fields, data) }.must_output(/.*NAME.*/, "")
    end

    it "should print field value" do
      proc { adapter.print_collection(fields, data) }.must_output(/.*John Doe.*/, "")
    end

    context "pagination" do
      it "should print pagination info if data are not complete" do
        data = HammerCLI::Output::RecordCollection.new([record], { :total => 2, :page => 1, :per_page => 1, :subtotal => 2 })
        proc { adapter.print_collection(fields, data) }.must_output(/.*Page 1 of 2 (use --page and --per-page for navigation)*/, "")
      end

      it "should print pagination info if data are complete" do
        data = HammerCLI::Output::RecordCollection.new([record], { :total => 1, :page => 1, :per_page => 1, :subtotal => 1 })
        proc { adapter.print_collection(fields, data) }.must_output("--------\nNAME    \n--------\nJohn Doe\n--------\n", "")
      end
    end

    context "handle ids" do
      let(:field_id) { Fields::Id.new(:path => [:some_id], :label => "Id") }
      let(:fields) {
        [field_name, field_id]
      }

      it "should ommit column of type Id by default" do
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.wont_match(/.*ID.*/)
      end

      it "should ommit column of type Id by default but no data" do
        expected_output = [
                           "----",
                           "NAME",
                           "----",
                           ""
                          ].join("\n")
        proc { adapter.print_collection(fields, empty_data) }.must_output(expected_output)
      end

      it "should print column of type Id when --show-ids is set" do
        adapter = HammerCLI::Output::Adapter::Table.new( { :show_ids => true } )
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*ID.*/)
      end

      it "should print column of type ID when --show-ids is set but no data" do
        expected_output = [
                           "-----|---",
                           "NAME | ID",
                           "-----|---",
                           "",
                          ].join("\n")
        adapter = HammerCLI::Output::Adapter::Table.new( { :show_ids => true } )
        proc { adapter.print_collection(fields, empty_data) }.must_output(expected_output)
      end
    end

    context "column width" do

      it "truncates string when it exceeds maximum width" do
        first_field = Fields::Field.new(:path => [:long], :label => "Long", :max_width => 10)
        fields = [first_field, field_lastname]

        expected_output = [
          "-----------|---------",
          "LONG       | LASTNAME",
          "-----------|---------",
          "SomeVer... | Doe     ",
          "-----------|---------",
          ""
        ].join("\n")

        proc { adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "truncates string when it exceeds width" do
        first_field = Fields::Field.new(:path => [:long], :label => "Long", :width => 10)
        fields = [first_field, field_lastname]

        expected_output = [
          "-----------|---------",
          "LONG       | LASTNAME",
          "-----------|---------",
          "SomeVer... | Doe     ",
          "-----------|---------",
          ""
        ].join("\n")

        proc { adapter.print_collection(fields, data) }.must_output(expected_output)
      end

    it "sets width to the longest column name when no data" do
      first_field = Fields::Field.new(:path => [:long], :label => "VeryLongTableHeaderName")
      fields = [first_field, field_lastname]

      expected_output = [
                         "------------------------|---------",
                         "VERYLONGTABLEHEADERNAME | LASTNAME",
                         "------------------------|---------",
                         ""
                        ].join("\n")
      proc { adapter.print_collection(fields, empty_data) }.must_output(expected_output)
    end

      it "sets certain width" do
        first_field = Fields::Field.new(:path => [:long], :label => "Long", :width => 25)
        fields = [first_field, field_lastname]

        expected_output = [
          "--------------------------|---------",
          "LONG                      | LASTNAME",
          "--------------------------|---------",
          "SomeVeryLongString        | Doe     ",
          "--------------------------|---------",
          ""
        ].join("\n")

        proc { adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "sets certain width when no data" do
        first_field = Fields::Field.new(:path => [:long], :label => "Long", :width => 25)
        fields = [first_field, field_lastname]

        expected_output = [
          "--------------------------|---------",
          "LONG                      | LASTNAME",
          "--------------------------|---------",
          ""
        ].join("\n")

        proc { adapter.print_collection(fields, empty_data) }.must_output(expected_output)
      end


      it "gives preference to width over maximal width" do
        first_field = Fields::Field.new(:path => [:long], :label => "Long", :width => 25, :max_width => 10)
        fields = [first_field, field_lastname]

        expected_output = [
          "--------------------------|---------",
          "LONG                      | LASTNAME",
          "--------------------------|---------",
          "SomeVeryLongString        | Doe     ",
          "--------------------------|---------",
          ""
        ].join("\n")

        proc { adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "gives preference to width over maximal width when no data" do
        first_field = Fields::Field.new(:path => [:long], :label => "Long", :width => 25, :max_width => 10)
        fields = [first_field, field_lastname]

        expected_output = [
          "--------------------------|---------",
          "LONG                      | LASTNAME",
          "--------------------------|---------",
          ""
        ].join("\n")

        proc { adapter.print_collection(fields, empty_data) }.must_output(expected_output)
      end


    end

    context "formatters" do
      it "should apply formatters" do
        class DotFormatter < HammerCLI::Output::Formatters::FieldFormatter
          def format(data, field_params={})
            '-DOT-'
          end
        end

        adapter = HammerCLI::Output::Adapter::Table.new({}, { :Field => [ DotFormatter.new ]})
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*-DOT-.*/)
      end

      it "should not break formatting" do
        class SliceFormatter < HammerCLI::Output::Formatters::FieldFormatter
          def format(data, field_params={})
            data[0..5]
          end
        end

        adapter = HammerCLI::Output::Adapter::Table.new({}, { :Field => [ SliceFormatter.new ]})

        expected_output = [
          "------",
          "FULL  ",
          "------",
          "SomeVe",
          "------",
          ""
        ].join("\n")

        proc { adapter.print_collection([field_long], data) }.must_output(expected_output)
      end

    end

    context "sort_columns" do
      let(:fields) {
        [field_firstname, field_lastname]
      }

      it "should sort output" do

        table_print_output = [
          "LASTNAME | FIRSTNAME",
          "---------|----------",
          "Doe      | John     "
        ].join("\n")

        expected_output = [
          "----------|---------",
          "FIRSTNAME | LASTNAME",
          "----------|---------",
          "John      | Doe     ",
          "----------|---------",
          ""
        ].join("\n")

        TablePrint::Printer.any_instance.stubs(:table_print).returns(table_print_output)
        proc { adapter.print_collection(fields, data) }.must_output(expected_output)
      end
    end
  end

end
