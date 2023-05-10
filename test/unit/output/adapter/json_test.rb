require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Json do

  let(:context) {{}}
  let(:adapter) { HammerCLI::Output::Adapter::Json.new(context, HammerCLI::Output::Output.formatters) }

  it "forbids default pagination" do
    _(adapter.paginate_by_default?).must_equal false
  end

  context "print_message" do
    it "prints the message" do
      params = { :a => 'Test', :b => 83 }
      msg = "Rendered with %{a} and %{b}"
      expected_output = [
        '{',
        '  "message": "Rendered with Test and 83"',
        '}',
        ''
      ].join("\n")

      _{ adapter.print_message(msg, params) }.must_output(expected_output)
    end

    it "prints the message with name and id" do
      params = { :name => 'Test', :id => 83 }
      msg = "Rendered with %{name} and %{id}"
      expected_output = [
        '{',
        '  "message": "Rendered with Test and 83",',
        '  "id": 83,',
        '  "name": "Test"',
        '}',
        ''
      ].join("\n")

      _{ adapter.print_message(msg, params) }.must_output(expected_output)
    end

    it 'prints the message with nil params' do
      params = nil
      msg = 'MESSAGE'
      expected_output = [
        '{',
        '  "message": "MESSAGE"',
        '}',
        ''
      ].join("\n")
      _{ adapter.print_message(msg, params) }.must_output(expected_output)
    end
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
    let(:num_one_contact)  { Fields::Collection.new(:path => [:one_contact], :label => "Contacts") }
    let(:contacts)      { Fields::Collection.new(:path => [:contacts], :label => "Contacts", :numbered => false) }
    let(:one_contact)      { Fields::Collection.new(:path => [:one_contact], :label => "Contacts", :numbered => false) }
    let(:desc)          { Fields::Field.new(:path => [:desc], :label => "Description") }
    let(:contact)       { Fields::Field.new(:path => [:contact], :label => "Contact") }
    let(:params)        { Fields::KeyValueList.new(:path => [:params], :label => "Parameters") }
    let(:params_collection) { Fields::Collection.new(:path => [:params], :label => "Parameters") }
    let(:param)             { Fields::KeyValue.new(:path => nil, :label => nil) }
    let(:blank)             { Fields::Field.new(:path => [:blank], :label => "Blank", :hide_blank => true) }
    let(:login)             { Fields::Field.new(:path => [:login], :label => "Login") }
    let(:missing)           { Fields::Field.new(:path => [:missing], :label => "Missing", :hide_missing => false) }

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
      :one_contact => [
        {
          :desc => 'personal email',
          :contact => 'john.doe@doughnut.com'
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
      fields = [firstname]
      expected_output = JSON.pretty_generate([{ 'Name' => 'John' }]) + "\n"
      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should field with nested data" do
      fields = [address_city]
      expected_output = JSON.pretty_generate([{ 'City' => 'New York' }]) + "\n"

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print labeled fields" do
      label_address.output_definition.append [city]
      fields = [label_address]
      hash = [{
                'Address' => {
                  'City' => 'New York'
                }
              }]
      expected_output = JSON.pretty_generate(hash) + "\n"
      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print collection" do
      num_contacts.output_definition.append [desc, contact]
      fields = [num_contacts]
      hash = [{
                'Contacts' => {
                  1 => {
                    'Description' => 'personal email',
                    'Contact' => 'john.doe@doughnut.com'
                  },
                  2 => {
                    'Description' => 'telephone',
                    'Contact' => '123456789'
                  }
                }
              }]

      expected_output = JSON.pretty_generate(hash) + "\n"
      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print collection with one element" do
      num_one_contact.output_definition.append [desc, contact]
      fields = [num_one_contact]
      hash = [{
                'Contacts' => {
                  1 => {
                    'Description' => 'personal email',
                    'Contact' => 'john.doe@doughnut.com'
                  }
                }
              }]

      expected_output = JSON.pretty_generate(hash) + "\n"
      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print unnumbered collection" do
      contacts.output_definition.append [desc, contact]
      fields = [contacts]
      hash = [{
                'Contacts' => [
                               {
                                 'Description' => 'personal email',
                                 'Contact' => 'john.doe@doughnut.com'
                               },
                               {
                                 'Description' => 'telephone',
                                 'Contact' => '123456789'
                               }]
              }]

      expected_output = JSON.pretty_generate(hash) + "\n"
      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print unnumbered collection with one element" do
      one_contact.output_definition.append [desc, contact]
      fields = [one_contact]
      hash = [{
                'Contacts' => [
                               {
                                 'Description' => 'personal email',
                                 'Contact' => 'john.doe@doughnut.com'
                               }]
              }]

      expected_output = JSON.pretty_generate(hash) + "\n"
      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end


    it "hides ids by default" do
      fields = [id, firstname]
      hash = [{'Name' => 'John'}]
      expected_output = JSON.pretty_generate(hash) + "\n"

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "skips blank values" do
      fields = [firstname, blank]
      hash = [{'Name' => 'John'}]
      expected_output = JSON.pretty_generate(hash) + "\n"

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "does not print fields which data are missing from api by default" do
      fields = [surname, login]
      hash = [{ 'Surname' => 'Doe' }]
      expected_output = JSON.pretty_generate(hash) + "\n"

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "prints fields which data are missing from api when field has hide_missing flag set to false" do
      fields = [surname, missing]
      hash = [{ 'Surname' => 'Doe', 'Missing' => '' }]
      expected_output = JSON.pretty_generate(hash) + "\n"

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print key -> value" do
      params_collection.output_definition.append [param]
      fields = [params_collection]

      hash = [{
                'Parameters' => {
                  1 => {
                    :name => 'weight',
                    :value => '83'
                  },
                  2 => {
                    :name => 'size',
                    :value => '32'
                  }
                }
              }]
      expected_output = JSON.pretty_generate(hash) + "\n"

      _{ adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    context 'capitalization' do
      let(:fields)   { [firstname, surname] }
      let(:raw_hash) { { 'Name' => 'John', 'Surname' => 'Doe' } }
      let(:settings) { HammerCLI::Settings }
      let(:context) { { :capitalization => HammerCLI.capitalization } }

      it 'should respect selected downcase capitalization' do
        settings.load({ :ui => { :capitalization => :downcase } })
        hash = [raw_hash.transform_keys(&:downcase)]
        expected_output = JSON.pretty_generate(hash) + "\n"
        out, = capture_io do
          adapter.print_collection(fields, data)
        end
        _(out).must_equal(expected_output)
      end

      it 'should respect selected capitalize capitalization' do
        settings.load({ :ui => { :capitalization => :capitalize } })
        hash = [raw_hash.transform_keys(&:capitalize)]
        expected_output = JSON.pretty_generate(hash) + "\n"
        out, = capture_io do
          adapter.print_collection(fields, data)
        end
        _(out).must_equal(expected_output)
      end

      it 'should respect selected upcase capitalization' do
        settings.load({ :ui => { :capitalization => :upcase } })
        hash = [raw_hash.transform_keys(&:upcase)]
        expected_output = JSON.pretty_generate(hash) + "\n"
        out, = capture_io do
          adapter.print_collection(fields, data)
        end
        _(out).must_equal(expected_output)
      end

      it 'should print a warn for not supported capitalization' do
        settings.load({ :ui => { :capitalization => :unsupported } })
        hash = [raw_hash]
        expected_error = "Cannot use such capitalization. Try one of downcase, capitalize, upcase.\n"
        expected_output = JSON.pretty_generate(hash) + "\n"
        out, err = capture_io do
          adapter.print_collection(fields, data)
        end
        _(out).must_equal(expected_output)
        _(err).must_equal(expected_error)
      end

      it "shouldn't change capitalization if wasn't selected" do
        settings.load({ :ui => { :capitalization => nil } })
        hash = [raw_hash]
        expected_output = JSON.pretty_generate(hash) + "\n"
        out, = capture_io do
          adapter.print_collection(fields, data)
        end
        _(out).must_equal(expected_output)
      end
    end

    context 'printing by chunks' do
      let(:settings) { HammerCLI::Settings }
      let(:context) { { show_ids: true, capitalization: HammerCLI.capitalization } }
      let(:collection_count) { 30 }
      let(:collection) do
        collection_count.times.each_with_object([]) do |t, r|
          r << { id: t, name: "John #{t}"}
        end
      end
      let(:collection_data) do
        HammerCLI::Output::RecordCollection.new(collection)
      end
      let(:fields) { [id, firstname] }

      before do
        settings.load(ui: { capitalization: :downcase })
      end

      it 'prints single chunk' do
        expected_output = JSON.pretty_generate(collection) + "\n"

        out, _err = capture_io do
          adapter.print_collection(fields, collection_data)
        end
        _(out).must_equal(expected_output)
      end

      it 'prints first chunk' do
        expected_output = JSON.pretty_generate(collection[0...10])[0...-2] + ",\n"

        out, _err = capture_io do
          adapter.print_collection(
            fields, collection_data[0...10], current_chunk: :first
          )
        end
        _(out).must_equal(expected_output)
      end

      it 'prints another chunk' do
        expected_output = JSON.pretty_generate(collection[10...20])[2...-2] + ",\n"

        out, _err = capture_io do
          adapter.print_collection(
            fields, collection_data[10...20], current_chunk: :another
          )
        end
        _(out).must_equal(expected_output)
      end

      it 'prints last chunk' do
        expected_output = JSON.pretty_generate(collection[20...30])[2..-1] + "\n"

        out, _err = capture_io do
          adapter.print_collection(
            fields, collection_data[20...30], current_chunk: :last
          )
        end
        _(out).must_equal(expected_output)
      end
    end

    context "show ids" do

      let(:context) { {:show_ids => true} }

      it "shows ids if it's required in the context" do
        fields = [id, firstname]
        hash = [{
                  'Id' => 112,
                  'Name' => 'John'
                }]
        expected_output = JSON.pretty_generate(hash) + "\n"
        _{ adapter.print_collection(fields, data) }.must_output(expected_output)
      end

    end

    context "output_stream" do

      let(:tempfile) { Tempfile.new("output_stream_json_test_temp") }
      let(:context) { {:output_file => tempfile} }

      it "should not print to stdout when --output-file is set" do
        fields = [firstname]

        _{ adapter.print_collection(fields, data) }.must_output("")
      end

      it "should print to file if --output-file is set" do
        fields = [firstname]
        hash = [{
                  'Name' => 'John'
                }]
        expected_output = JSON.pretty_generate(hash) + "\n"

        adapter.print_collection(fields, data)
        tempfile.close
        _(IO.read(tempfile.path)).must_equal(expected_output)
      end

    end

  end

end
