require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Base do

  let(:adapter) { HammerCLI::Output::Adapter::Base.new }

  context "print_collection" do

    let(:name)          { Fields::DataField.new(:path => [:name], :label => "Name") }
    let(:surname)       { Fields::DataField.new(:path => [:surname], :label => "Surname") }
    let(:address_city)  { Fields::DataField.new(:path => [:address, :city], :label => "City") }
    let(:city)          { Fields::DataField.new(:path => [:city], :label => "City") }
    let(:label_address) { Fields::Label.new(:path => [:address], :label => "Adress") }
    let(:contacts)      { Fields::Collection.new(:path => [:address], :label => "Contacts") }
    let(:desc)          { Fields::DataField.new(:path => [:desc], :label => "Description") }
    let(:contact)       { Fields::DataField.new(:path => [:contact], :label => "Contact") }

    let(:data) { HammerCLI::Output::RecordCollection.new [{
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
      ]
    }]}

    it "should print one field" do
      fields = [name]
      expected_output = [
        "Name:  John",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should align two fields" do
      fields = [name, surname]
      expected_output = [
        "Name:     John",
        "Surname:  Doe",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should field with nested data" do
      fields = [address_city]
      expected_output = [
        "City:  New York",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end

    it "should print labeled fields" do
      label_address.output_definition.append [city]
      fields = [label_address]

      expected_output = [
        "Address",
        "  City:  New York",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end


    it "should print collection" do
      contacts.output_definition.append [contact, desc]
      fields = [contacts]

      expected_output = [
        "Contacts",
        "  Description:  personal email",
        "  Contact:  john.doe@doughnut.com",
        "  Description:  telephone",
        "  Contact:  123456789",
        "\n"
      ].join("\n")

      proc { adapter.print_collection(fields, data) }.must_output(expected_output)
    end


  end

end
