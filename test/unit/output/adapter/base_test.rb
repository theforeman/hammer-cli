require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Base do

  let(:context) {{}}
  let(:adapter) { HammerCLI::Output::Adapter::Base.new(context, HammerCLI::Output::Output.formatters) }

  it "allows default pagination" do
    adapter.paginate_by_default?.must_equal true
  end

  context "print_collection" do

    let(:id)            { Fields::Id.new(:path => [:id], :label => "Id") }
    let(:name)          { Fields::Field.new(:path => [:name], :label => "Name") }
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
      ]
    }]}

    it "should print one field" do
      fields = [name]
      expected_output = [
        "Name: John",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "doesn't print label when it's nil" do
      fields = [unlabeled]
      expected_output = [
        "John",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "aligns multiple fields" do
      fields = [name, surname, unlabeled]
      expected_output = [
        "Name:    John",
        "Surname: Doe",
        "John",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should field with nested data" do
      fields = [address_city]
      expected_output = [
        "City: New York",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print labeled fields" do
      label_address.output_definition.append [city]
      fields = [label_address]

      expected_output = [
        "Address: ",
        "    City: New York",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
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

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
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

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "hides ids by default" do
      fields = [id, name]
      expected_output = [
        "Name: John",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "skips blank values" do
      fields = [name, blank]
      expected_output = [
        "Name: John",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "does not print fields which data are missing from api by default" do
      fields = [name, login]
      expected_output = [
        "Name: John",
        "\n"
      ].join("\n")
      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "prints fields which data are missing from api when field has hide_missing flag set to false" do
      fields = [name, missing]
      expected_output = [
        "Name:    John",
        "Missing:",
        "\n"
      ].join("\n")
      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
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

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
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
      let(:fields) { [id, name] }

      it 'prints single chunk' do
        expected_output = collection_count.times.each_with_object([]) do |t, r|
          r << ["Id:   #{t}", "Name: John #{t}", "\n"].join("\n")
        end.flatten(1).join

        proc do
          adapter.print_collection(fields, collection_data)
        end.must_output(expected_output)
      end

      it 'prints first chunk' do
        expected_output = 10.times.each_with_object([]) do |t, r|
          r << ["Id:   #{t}", "Name: John #{t}", "\n"].join("\n")
        end.flatten(1).join

        proc do
          adapter.print_collection(
            fields, collection_data[0...10], current_chunk: :first
          )
        end.must_output(expected_output)
      end

      it 'prints another chunk' do
        expected_output = (10...20).each_with_object([]) do |t, r|
          r << ["Id:   #{t}", "Name: John #{t}", "\n"].join("\n")
        end.flatten(1).join

        proc do
          adapter.print_collection(
            fields, collection_data[10...20], current_chunk: :another
          )
        end.must_output(expected_output)
      end

      it 'prints last chunk' do
        expected_output = (20...30).each_with_object([]) do |t, r|
          r << ["Id:   #{t}", "Name: John #{t}", "\n"].join("\n")
        end.flatten(1).join

        proc do
          adapter.print_collection(
            fields, collection_data[20...30], current_chunk: :last
          )
        end.must_output(expected_output)
      end
    end

    context "show ids" do

      let(:context) { {:show_ids => true} }

      it "shows ids if it's required in the context" do
        fields = [id, name]
        expected_output = [
          "Id:   112",
          "Name: John",
          "\n"
        ].join("\n")

        proc { adapter.print_collection(fields, data) }.must_output(expected_output)
      end

    end

    context "output_stream" do

      let(:tempfile) { Tempfile.new("output_stream_base_test_temp") }
      let(:context) { {:output_file => tempfile} }

      it "should not print to stdout when --output-file is set" do
        fields = [name]

        proc { adapter.print_collection(fields, data) }.must_output("")
      end

      it "should print to file if --output-file is set" do
        fields = [name]
        expected_output = [
          "Name: John",
          "\n"
        ].join("\n")

        adapter.print_collection(fields, data)
        tempfile.close
        IO.read(tempfile.path).must_equal(expected_output)
      end

    end

    context 'print_message' do
      it 'should print message with nil params' do
        proc { adapter.print_message('MESSAGE', nil) }.must_output(/.*MESSAGE.*/, '')
      end
    end
  end

end
