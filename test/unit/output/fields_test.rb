require File.join(File.dirname(__FILE__), '../test_helper')


describe Fields::Field do

  let(:field) { Fields::Field.new }

  describe "get_value" do
    it "should exist" do
      assert field.respond_to? :get_value
    end

    it "should take data as a parameter" do
      field.method(:get_value).arity.must_equal 1
    end
  end

end

describe Fields::LabeledField do

  let(:label) { "Some Label" }
  let(:field) { Fields::LabeledField.new :label => label }

  context "labels" do
    it "has label" do
      assert field.respond_to? :label
    end

    it "is possible to set label in constructor" do
      field.label.must_equal label
    end
  end

end

describe Fields::DataField do

  let(:symbol_data) {{
    :name => "John Doe",
    :email => "john.doe@example.com",
    :address => {
      :city => {
        :name => "New York",
        :zip => "1234"
      }
    }
  }}

  let(:string_data) {{
    "name" => "Eric Doe",
    "email" => "eric.doe@example.com",
    "address" => {
      "city" => {
        "name" => "Boston",
        "zip" => "6789"
      }
    }
  }}

  let(:label) { "Some Label" }
  let(:path) { [:address, :city, :name] }
  let(:field) { Fields::DataField.new :label => label, :path => path }

  it "stores label from constructor" do
    field.label.must_equal label
  end

  it "stores path from constructor" do
    field.path.must_equal path
  end

  it "default path should be empty array" do
    Fields::DataField.new.path.must_equal []
  end

  context "getting data" do

    it "should pick correct value" do
      field.get_value(symbol_data).must_equal symbol_data[:address][:city][:name]
    end

    it "should pick correct value independent of key type" do
      field.get_value(string_data).must_equal string_data["address"]["city"]["name"]
    end

    it "should pick correct value even if data contains empty key (#3352)" do
      string_data[''] = {}
      field.get_value(string_data).must_equal string_data["address"]["city"]["name"]
    end


  end

end


