require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Base do

  let(:context) {{}}
  let(:adapter) { HammerCLI::Output::Adapter::Base.new(context, HammerCLI::Output::Output.formatters) }

  context "print_collection" do

    let(:id)            { Fields::Id.new(:path => [:id], :label => "Id") }
    let(:name)          { Fields::Field.new(:path => [:name], :label => "Name") }
    let(:unlabeled)     { Fields::Field.new(:path => [:name]) }
    let(:surname)       { Fields::Field.new(:path => [:surname], :label => "Surname") }
    let(:address_city)  { Fields::Field.new(:path => [:address, :city], :label => "City") }
    let(:city)          { Fields::Field.new(:path => [:city], :label => "City") }
    let(:label_address) { Fields::Label.new(:path => [:address], :label => "Address") }
    let(:contacts)      { Fields::Collection.new(:path => [:contacts], :label => "Contacts") }
    let(:desc)          { Fields::Field.new(:path => [:desc], :label => "Description") }
    let(:contact)       { Fields::Field.new(:path => [:contact], :label => "Contact") }
    let(:params)        { Fields::KeyValueList.new(:path => [:params], :label => "Parameters") }
    let(:params_collection) { Fields::Collection.new(:path => [:params], :label => "Parameters") }
    let(:param)             { Fields::KeyValue.new(:path => nil, :label => nil) }
    let(:blank)             { Fields::Field.new(:path => [:blank], :label => "Blank", :hide_blank => true) }

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
        "  City: New York",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end


    it "should print collection" do
      contacts.output_definition.append [desc, contact]
      fields = [contacts]

      expected_output = [
        "Contacts: ",
        "  Description: personal email",
        "  Contact:     john.doe@doughnut.com",
        "  Description: telephone",
        "  Contact:     123456789",
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

    it "should print key -> value" do
      params_collection.output_definition.append [param]
      fields = [params_collection]

      expected_output = [
        "Parameters: ",
        "  weight => 83",
        "  size => 32",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
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

  end

end
