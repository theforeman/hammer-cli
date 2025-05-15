require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Base do

  let(:context) {{}}
  let(:adapter) { HammerCLI::Output::Adapter::Base.new(context, HammerCLI::Output::Output.formatters) }

  it "allows default pagination" do
    _(adapter.paginate_by_default?).must_equal true
  end

  context "print_collection" do

    let(:id)            { Fields::Id.new(:path => [:id], :label => "Id") }
    let(:firstname)     { Fields::Field.new(:path => [:name], :label => "Name") }
    let(:unlabeled)     { Fields::Field.new(:path => [:name]) }
    let(:surname)       { Fields::Field.new(:path => [:surname], :label => "Surname") }
    let(:address_city)  { Fields::Field.new(:path => [:address, :city], :label => "City") }
    let(:city)          { Fields::Field.new(:path => [:city], :label => "City") }
    let(:label_address) { Fields::Label.new(:path => [:address], :label => "Address") }
    let(:num_contacts)  { Fields::Collection.new(:path => [:contacts], :label => "Contacts") }
    let(:contacts)      { Fields::Collection.new(:path => [:contacts], :label => "Contacts", :numbered => false) }
    let(:desc)          { Fields::Field.new(:path => [:desc], :label => "Description") }
    let(:contact)       { Fields::Field.new(:path => [:contact], :label => "Contact") }
    let(:params)        { Fields::KeyValueList.new(:path => [:params], :label => "Parameters") }
    let(:params_collection) { Fields::Collection.new(:path => [:params], :label => "Parameters") }
    let(:param)             { Fields::KeyValue.new(:path => nil, :label => nil) }
    let(:blank)             { Fields::Field.new(:path => [:blank], :label => "Blank", :hide_blank => true) }
    let(:login)             { Fields::Field.new(:path => [:login], :label => "Login") }
    let(:missing)           { Fields::Field.new(:path => [:login], :label => "Missing", :hide_missing => false) }
    let (:deprecated_a) { Fields::Field.new(:path => [:deprecated_a], :label => "Deprecated", :deprecated => true) }
    let (:deprecated_b) { Fields::Field.new(:path => [:deprecated_b], :label => "Replaced by", :replaced_by_path => ["!p", "New field"]) }

    let(:data) { HammerCLI::Output::RecordCollection.new [{
      :id => 112,
      :name => "John",
      :surname => "Doe",
      :address => {
        :city => "New York"
      },
      :contacts => [
        {
          :desc => 'personal email',
          :contact => 'john.doe@doughnut.com'
        },
        {
          :desc => 'telephone',
          :contact => '123456789'
        }
      ],
      :params => [
        {
          :name => 'weight',
          :value => '83'
        },
        {
          :name => 'size',
          :value => '32'
        }
      ],
      :deprecated_a => 'deprecated_a',
      :deprecated_b => 'deprecated_b'
    }]}

    it "should print one field" do
      fields = [firstname]
      expected_output = [
        "Name: John",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "doesn't print label when it's nil" do
      fields = [unlabeled]
      expected_output = [
        "John",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "aligns multiple fields" do
      fields = [firstname, surname, unlabeled]
      expected_output = [
        "Name:    John",
        "Surname: Doe",
        "John",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should field with nested data" do
      fields = [address_city]
      expected_output = [
        "City: New York",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print labeled fields" do
      label_address.output_definition.append [city]
      fields = [label_address]

      expected_output = [
        "Address: ",
        "    City: New York",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end


    it "should print collection" do
      num_contacts.output_definition.append [desc, contact]
      fields = [num_contacts]

      expected_output = [
        "Contacts: ",
        " 1) Description: personal email",
        "    Contact:     john.doe@doughnut.com",
        " 2) Description: telephone",
        "    Contact:     123456789",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print unnumbered collection" do
      contacts.output_definition.append [desc, contact]
      fields = [contacts]

      expected_output = [
        "Contacts: ",
        "    Description: personal email",
        "    Contact:     john.doe@doughnut.com",
        "    Description: telephone",
        "    Contact:     123456789",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "hides ids by default" do
      fields = [id, firstname]
      expected_output = [
        "Name: John",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "skips blank values" do
      fields = [firstname, blank]
      expected_output = [
        "Name: John",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "does not print fields which data are missing from api by default" do
      fields = [firstname, login]
      expected_output = [
        "Name: John",
        "\n"
      ].join("\n")
      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "prints fields which data are missing from api when field has hide_missing flag set to false" do
      fields = [firstname, missing]
      expected_output = [
        "Name:    John",
        "Missing:",
        "\n"
      ].join("\n")
      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print key -> value" do
      params_collection.output_definition.append [param]
      fields = [params_collection]

      expected_output = [
        "Parameters: ",
        " 1) weight => 83",
        " 2) size => 32",
        "\n"
      ].join("\n")

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should warn about deprecated fields" do
      fields = [deprecated_a]

      expected_stdout= [
        "Deprecated: deprecated_a",
        "\n"
      ].join("\n")
      expected_stderr = "Warning: Field 'Deprecated' is deprecated and may be removed in future versions.\n"

      _{ adapter.print_collection(fields, data) }.must_output(stdout=expected_stdout, stderr=expected_stderr)
    end

    it "should warn about replaced fields" do
      fields = [deprecated_b]

      # Stubbing because parent/child relationship is not set up; covered in other tests
      adapter.stub(:resolve_full_label_from_path, "Parent field/New field") do
        expected_stdout= [
          "Replaced by: deprecated_b",
          "\n"
        ].join("\n")
        expected_stderr = "Warning: Field 'Replaced by' is deprecated. Consider using 'Parent field/New field' instead.\n"

        _{ adapter.print_collection(fields, data) }.must_output(stdout=expected_stdout, stderr=expected_stderr)
      end
    end

    context 'printing by chunks' do
      let(:context) { { show_ids: true } }
      let(:collection_count) { 30 }
      let(:collection_data) do
        collection = collection_count.times.each_with_object([]) do |t, r|
          r << { id: t, name: "John #{t}"}
        end
        HammerCLI::Output::RecordCollection.new(collection)
      end
      let(:fields) { [id, firstname] }

      it 'prints single chunk' do
        expected_output = collection_count.times.each_with_object([]) do |t, r|
          r << ["Id:   #{t}", "Name: John #{t}", "\n"].join("\n")
        end.flatten(1).join

        _{
          adapter.print_collection(fields, collection_data)
        }.must_output(expected_output)
      end

      it 'prints first chunk' do
        expected_output = 10.times.each_with_object([]) do |t, r|
          r << ["Id:   #{t}", "Name: John #{t}", "\n"].join("\n")
        end.flatten(1).join

        _{
          adapter.print_collection(
            fields, collection_data[0...10], current_chunk: :first
          )
        }.must_output(expected_output)
      end

      it 'prints another chunk' do
        expected_output = (10...20).each_with_object([]) do |t, r|
          r << ["Id:   #{t}", "Name: John #{t}", "\n"].join("\n")
        end.flatten(1).join

        _{
          adapter.print_collection(
            fields, collection_data[10...20], current_chunk: :another
          )
        }.must_output(expected_output)
      end

      it 'prints last chunk' do
        expected_output = (20...30).each_with_object([]) do |t, r|
          r << ["Id:   #{t}", "Name: John #{t}", "\n"].join("\n")
        end.flatten(1).join

        _{
          adapter.print_collection(
            fields, collection_data[20...30], current_chunk: :last
          )
        }.must_output(expected_output)
      end
    end

    context "show ids" do

      let(:context) { {:show_ids => true} }

      it "shows ids if it's required in the context" do
        fields = [id, firstname]
        expected_output = [
          "Id:   112",
          "Name: John",
          "\n"
        ].join("\n")

        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
      end

    end

    context "output_stream" do

      let(:tempfile) { Tempfile.new("output_stream_base_test_temp") }
      let(:context) { {:output_file => tempfile} }

      it "should not print to stdout when --output-file is set" do
        fields = [firstname]

        _{ adapter.print_collection(fields, data) }.must_output("")
      end

      it "should print to file if --output-file is set" do
        fields = [firstname]
        expected_output = [
          "Name: John",
          "\n"
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
