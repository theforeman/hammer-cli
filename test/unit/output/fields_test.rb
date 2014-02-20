require File.join(File.dirname(__FILE__), '../test_helper')



describe Fields::Field do

  let(:label) { "Some Label" }
  let(:path) { [:address, :city, :name] }
  let(:field) { Fields::Field.new :label => label, :path => path }


  it "stores label from constructor" do
    field.label.must_equal label
  end

  it "stores path from constructor" do
    field.path.must_equal path
  end

  it "default path should be empty array" do
    Fields::Field.new.path.must_equal []
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


