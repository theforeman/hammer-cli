require File.join(File.dirname(__FILE__), '../test_helper')



describe Fields::Field do

  let(:label) { "Some Label" }
  let(:path) { [:address, :city, :name] }
  let(:field) { Fields::Field.new :label => label, :path => path }
  let(:blank_field) { Fields::Field.new :label => label, :path => path, :hide_blank => true }


  it "stores label from constructor" do
    field.label.must_equal label
  end

  it "stores path from constructor" do
    field.path.must_equal path
  end

  it "default path should be empty array" do
    Fields::Field.new.path.must_equal []
  end


  describe "display?" do

    context "blank is allowed" do

      it "returns false the value is nil" do
        field.display?(nil).must_equal true
      end

      it "returns true when there is some data under the path" do
        field.display?("some value").must_equal true
      end
    end


    context "blank is not allowed" do

      it "returns false the value is nil" do
        blank_field.display?(nil).must_equal false
      end

      it "returns true when there is some data under the path" do
        blank_field.display?("some value").must_equal true
      end
    end

  end

  describe "hide_blank?" do

    it "defaults to false" do
      Fields::Field.new.hide_blank?.must_equal false
    end

    it "can be set to true in the constructor" do
      blank_field.hide_blank?.must_equal true
    end

  end

end


describe Fields::ContainerField do

  describe "display?" do

    context "blank is allowed" do
      let(:field) { Fields::ContainerField.new :label => "Label" }

      it "returns false the value is nil" do
        field.display?(nil).must_equal true
      end

      it "returns false the value is empty array" do
        field.display?([]).must_equal true
      end

      it "returns false the value is empty hash" do
        field.display?({}).must_equal true
      end

      it "returns true when there is some data under the path" do
        field.display?(["some value"]).must_equal true
      end

    end

    context "blank is not allowed" do
      let(:field) { Fields::ContainerField.new :label => "Label", :hide_blank => true }

      it "returns false the value is nil" do
        field.display?(nil).must_equal false
      end

      it "returns false the value is empty array" do
        field.display?([]).must_equal false
      end

      it "returns false the value is empty hash" do
        field.display?({}).must_equal false
      end

      it "returns true when there is some data under the path" do
        field.display?(["some value"]).must_equal true
      end

    end

  end

end
