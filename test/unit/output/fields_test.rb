require File.join(File.dirname(__FILE__), '../test_helper')



describe Fields::Field do

  let(:label) { "Some Label" }
  let(:field) { Fields::Field.new :label => label }

  describe "get_value" do
    it "should exist" do
      assert field.respond_to? :get_value
    end

    it "should take data as a parameter" do
      field.method(:get_value).arity.must_equal 1
    end
  end

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
  let(:wrong_path) { [:address, :city, :wrong_key] }
  let(:field) { Fields::DataField.new :label => label, :path => path }
  let(:blank_field) { Fields::DataField.new :label => label, :path => wrong_path, :skip_blank => true }

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

  # describe "blank?" do

  #   it "returns true when the data under the path is nil" do
  #     blank_field.blank?.must_equal true
  #   end

  #   it "returns false when there is some data under the path" do
  #     field.blank?.must_equal false
  #   end

  # end

  # describe "skip_blank?" do

  #   it "defaults to false" do
  #     field.skip_blank?.must_equal false
  #   end

  #   it "can be set to true in the constructor" do
  #     blank_field.skip_blank?.must_equal false
  #   end

  # end

end


