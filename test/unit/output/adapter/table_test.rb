require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Table do

  let(:adapter) { HammerCLI::Output::Adapter::Table.new }

  it "allows default pagination" do
    _(adapter.paginate_by_default?).must_equal true
  end

  context "print_collection" do
    let(:field_id) { Fields::Id.new(:path => [:id], :label => "Id") }
    let(:field_name) { Fields::Field.new(:path => [:fullname], :label => "Name") }
    let(:field_firstname) { Fields::Field.new(:path => [:firstname], :label => "Firstname") }
    let(:field_lastname) { Fields::Field.new(:path => [:lastname], :label => "Lastname") }
    let(:field_long) { Fields::Field.new(:path => [:long], :label => "Full") }
    let(:field_login) { Fields::Field.new(:path => [:login], :label => "Login") }
    let(:field_missing) { Fields::Field.new(:path => [:missing], :label => "Missing", :hide_missing => false) }

    let(:fields) {
      [field_name]
    }

    let(:red) { "\e[1;31m" }
    let(:reset) { "\e[0m" }

    let(:record) { {
      :id => 1,
      :firstname => "John",
      :lastname => "Doe",
      :two_column_chars => "文字漢字",
      :czech_chars => "žluťoučký kůň",
      :colorized_name => "#{red}John#{reset}",
      :fullname => "John Doe",
      :long => "SomeVeryLongString",
      :colorized_long => "#{red}SomeVeryLongString#{reset}",
      :two_column_long => "文字-Kanji-漢字-Hanja-漢字"
    } }
    let(:data) { HammerCLI::Output::RecordCollection.new [record] }
    let(:empty_data) { HammerCLI::Output::RecordCollection.new [] }

    it "should print column name " do
      _{ adapter.print_collection(fields, data) }.must_output(/.*NAME.*/, "")
    end

    it "should print field value" do
      _{ adapter.print_collection(fields, data) }.must_output(/.*John Doe.*/, "")
    end

    it "does not print fields which data are missing from api by default" do
      fields << field_login
      expected_output = [
        '--------',
        'NAME    ',
        '--------',
        'John Doe',
        '--------',
        ''
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "prints fields which data are missing from api when field has hide_missing flag set to false" do
      fields << field_missing
      expected_output = [
        '---------|--------',
        'NAME     | MISSING',
        '---------|--------',
        'John Doe |        ',
        '---------|--------',
        ''
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    context "pagination" do
      it "should print pagination info if data are not complete" do
        data = HammerCLI::Output::RecordCollection.new([record], { :total => 2, :page => 1, :per_page => 1, :subtotal => 2 })
        _{ adapter.print_collection(fields, data) }.must_output(/.*Page 1 of 2 (use --page and --per-page for navigation)*/, "")
      end

      it "should print pagination info if data are complete" do
        data = HammerCLI::Output::RecordCollection.new([record], { :total => 1, :page => 1, :per_page => 1, :subtotal => 1 })
        _{ adapter.print_collection(fields, data) }.must_output("--------\nNAME    \n--------\nJohn Doe\n--------\n", "")
      end
    end

    context "handle ids" do
      let(:field_id) { Fields::Id.new(:path => [:some_id], :label => "Id", :hide_missing => false) }
      let(:fields) {
        [field_name, field_id]
      }

      it "should ommit column of type Id by default" do
        out, _ = capture_io { adapter.print_collection(fields, data) }
        _(out).wont_match(/.*ID.*/)
      end

      it "should ommit column of type Id by default but no data" do
        expected_output = [
                           "----",
                           "NAME",
                           "----",
                           ""
                          ].join("\n")
        _{ adapter.print_collection(fields, empty_data) }.must_output(expected_output)
      end

      it "should print column of type Id when --show-ids is set" do
        adapter = HammerCLI::Output::Adapter::Table.new( { :show_ids => true } )
        out, _ = capture_io { adapter.print_collection(fields, data) }
        _(out).must_match(/.*ID.*/)
      end

      it "should print column of type ID when --show-ids is set but no data" do
        expected_output = [
                           "-----|---",
                           "NAME | ID",
                           "-----|---",
                           "",
                          ].join("\n")
        adapter = HammerCLI::Output::Adapter::Table.new( { :show_ids => true } )
        _{ adapter.print_collection(fields, empty_data) }.must_output(expected_output)
      end
    end

    context "handle headers" do
      it "should print headers by default" do
        out, _ = capture_io { adapter.print_collection(fields, data) }
        _(out).must_match(/.*NAME.*/)
      end

      it "should print headers by default even if there is no data" do
        out, _ = capture_io { adapter.print_collection(fields, empty_data) }
        _(out).must_match(/.*NAME.*/)
      end

      it "should print data only when --no-headers is set" do
        expected_output = [
                           "John Doe",
                           "",
                          ].join("\n")
        adapter = HammerCLI::Output::Adapter::Table.new( { :no_headers => true } )
        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "should print nothing when --no-headers is set but no data" do
        expected_output = ""
        adapter = HammerCLI::Output::Adapter::Table.new( { :no_headers => true } )
        _{ adapter.print_collection(fields, empty_data) }.must_output(expected_output)
      end
    end

    context "column width" do

      it "calculates correct width of two-column characters" do
        first_field = Fields::Field.new(:path => [:two_column_chars], :label => "Some characters")
        fields = [first_field, field_lastname]

        expected_output = [
          "----------------|---------",
          "SOME CHARACTERS | LASTNAME",
          "----------------|---------",
          "文字漢字        | Doe     ",
          "----------------|---------",
          ""
        ].join("\n")

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "calculates correct width of czech characters" do
        first_field = Fields::Field.new(:path => [:czech_chars], :label => "Some characters")
        fields = [first_field, field_lastname]

        expected_output = [
          "----------------|---------",
          "SOME CHARACTERS | LASTNAME",
          "----------------|---------",
          "žluťoučký kůň   | Doe     ",
          "----------------|---------",
          ""
        ].join("\n")

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "calculates correct width of colorized strings" do
        first_field = Fields::Field.new(:path => [:colorized_name], :label => "Colorized name")
        fields = [first_field, field_lastname]

        expected_output = [
          "---------------|---------",
          "COLORIZED NAME | LASTNAME",
          "---------------|---------",
          "John           | Doe     ",
          "---------------|---------",
          ""
        ].join("\n").gsub('John', "#{red}John#{reset}")

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "truncates two-column characters when it exceeds maximum width" do
        first_field = Fields::Field.new(:path => [:two_column_long], :label => "Some characters", :max_width => 16)
        fields = [first_field, field_lastname]

        expected_output = [
          "-----------------|---------",
          "SOME CHARACTERS  | LASTNAME",
          "-----------------|---------",
          "文字-Kanji-漢... | Doe     ",
          "-----------------|---------",
          ""
        ].join("\n")

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "truncates colorized string string when it exceeds maximum width" do
        first_field = Fields::Field.new(:path => [:colorized_long], :label => "Long", :max_width => 10)
        fields = [first_field, field_lastname]

        expected_output = [
          "-----------|---------",
          "LONG       | LASTNAME",
          "-----------|---------",
          "SomeVer... | Doe     ",
          "-----------|---------",
          ""
        ].join("\n").gsub('SomeVer', "#{red}SomeVer#{reset}")

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
      end

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

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
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

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
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
        _{ adapter.print_collection(fields, empty_data) }.must_output(expected_output)
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

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
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

        _{ adapter.print_collection(fields, empty_data) }.must_output(expected_output)
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

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
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

        _{ adapter.print_collection(fields, empty_data) }.must_output(expected_output)
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
        out, _ = capture_io { adapter.print_collection(fields, data) }
        _(out).must_match(/.*-DOT-.*/)
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

        _{ adapter.print_collection([field_long], data) }.must_output(expected_output)
      end

    end

    context 'printing by chunks' do
      let(:adapter) { HammerCLI::Output::Adapter::Table.new(show_ids: true) }
      let(:collection_count) { 30 }
      let(:collection_data) do
        collection = collection_count.times.each_with_object([]) do |t, r|
          r << { id: t, fullname: "John Doe #{t}"}
        end
        HammerCLI::Output::RecordCollection.new(collection)
      end
      let(:fields) { [field_id, field_name] }

      it 'prints single chunk' do
        expected_output = collection_count.times.each_with_object([]) do |t, r|
          sp = t < 10 ? ' ' : ''
          r << ["#{t} #{sp}| John Doe #{t}#{sp}"]
        end.flatten(1).unshift(
          '---|------------',
          'ID | NAME       ',
          "---|------------",
        ).join("\n") + "\n---|------------\n"

        _{adapter.print_collection(fields, collection_data)}.must_output(expected_output)
      end

      it 'prints first chunk' do
        expected_output = (0...10).each_with_object([]) do |t, r|
          r << [
            "#{t}  | John Doe #{t}"
          ]
        end.flatten(1).unshift(
          '---|-----------',
          'ID | NAME      ',
          "---|-----------",
        ).join("\n") + "\n"

        _{adapter.print_collection(
          fields, collection_data[0...10], current_chunk: :first
        )}.must_output(expected_output)
      end

      it 'prints another chunk' do
        expected_output = (10...20).each_with_object([]) do |t, r|
          r << ["#{t} | John Doe #{t}"]
        end.flatten(1).join("\n") + "\n"

        _{adapter.print_collection(
          fields, collection_data[10...20], current_chunk: :another
        )}.must_output(expected_output)
      end
      #
      it 'prints last chunk' do
        expected_output = (20...30).each_with_object([]) do |t, r|
          r << ["#{t} | John Doe #{t}"]
        end.flatten(1).join("\n") + "\n---|------------\n"

        _{adapter.print_collection(
          fields, collection_data[20...30], current_chunk: :last
        )}.must_output(expected_output)
      end
    end

    context "output_stream" do

      let(:tempfile) { Tempfile.new("output_stream_table_test_temp") }
      let(:context) { {:output_file => tempfile} }
      let(:adapter) { HammerCLI::Output::Adapter::Table.new(context, HammerCLI::Output::Output.formatters) }

      it "should not print to stdout when --output-file is set" do
        fields = [field_firstname]

        _{ adapter.print_collection(fields, data) }.must_output("")
      end

      it "should print to file if --output-file is set" do
        fields = [field_firstname]
        expected_output = [
          "---------",
          "FIRSTNAME",
          "---------",
          "John     ",
          "---------",
          ""
        ].join("\n")

        adapter.print_collection(fields, data)
        tempfile.close
        _(IO.read(tempfile.path)).must_equal(expected_output)
      end

    end

    context 'print_message' do
      it 'should print message with nil params' do
        _{ adapter.print_message('MESSAGE', nil) }.must_output(/.*MESSAGE.*/, '')
      end
    end
  end

end
