require File.join(File.dirname(__FILE__), '../test_helper')



describe Fields::Field do

  let(:label) { "Some Label" }
  let(:path) { [:address, :city, :name] }
  let(:field) { Fields::Field.new :label => label, :path => path, :some => :parameter }
  let(:blank_field) { Fields::Field.new :label => label, :path => path, :hide_blank => true }


  it "stores label from constructor" do
    _(field.label).must_equal label
  end

  it "stores path from constructor" do
    _(field.path).must_equal path
  end

  it "default path should be empty array" do
    _(Fields::Field.new.path).must_equal []
  end

  describe "parameters" do

    it "returns all parameters passed to a filed" do
      expected_params = {
        :label => label,
        :path => path,
        :some => :parameter
      }
      _(field.parameters).must_equal expected_params
    end

  end

  describe "display?" do

    context "blank is allowed" do

      it "returns false the value is nil" do
        _(field.display?(nil)).must_equal true
      end

      it "returns true when there is some data under the path" do
        _(field.display?("some value")).must_equal true
      end
    end


    context "blank is not allowed" do

      it "returns false the value is nil" do
        _(blank_field.display?(nil)).must_equal false
      end

      it "returns true when there is some data under the path" do
        _(blank_field.display?("some value")).must_equal true
      end
    end

  end

  describe "hide_blank?" do

    it "defaults to false" do
      _(Fields::Field.new.hide_blank?).must_equal false
    end

    it "can be set to true in the constructor" do
      _(blank_field.hide_blank?).must_equal true
    end

  end

end


describe Fields::ContainerField do

  describe "display?" do

    context "blank is allowed" do
      let(:field) { Fields::ContainerField.new :label => "Label" }

      it "returns false the value is nil" do
        _(field.display?(nil)).must_equal true
      end

      it "returns false the value is empty array" do
        _(field.display?([])).must_equal true
      end

      it "returns false the value is empty hash" do
        _(field.display?({})).must_equal true
      end

      it "returns true when there is some data under the path" do
        _(field.display?(["some value"])).must_equal true
      end

    end

    context "blank is not allowed" do
      let(:field) { Fields::ContainerField.new :label => "Label", :hide_blank => true }

      it "returns false the value is nil" do
        _(field.display?(nil)).must_equal false
      end

      it "returns false the value is empty array" do
        _(field.display?([])).must_equal false
      end

      it "returns false the value is empty hash" do
        _(field.display?({})).must_equal false
      end

      it "returns true when there is some data under the path" do
        _(field.display?(["some value"])).must_equal true
      end

    end

  end

end


describe Fields::Label do

  describe "display?" do

    context "blank is allowed" do
      let(:field) do
        Fields::Label.new :label => "Label" do
          field :a, "A"
          field :b, "B"
        end
      end

      it "returns true when all the keys are present" do
        _(field.display?({:a => 1, :b => 2})).must_equal true
      end

      it "returns true when some of the keys are present" do
        _(field.display?({:a => 1})).must_equal true
      end

      it "returns true the hash is empty" do
        _(field.display?({})).must_equal true
      end

      it "returns true the hash does not contain the required keys" do
        _(field.display?({:c => 3})).must_equal true
      end

    end

    context "blank is not allowed" do
      let(:field) do
        Fields::Label.new :label => "Label", :hide_blank => true do
          field :a, "A", Fields::Field, :hide_blank => true
          field :b, "B", Fields::Field, :hide_blank => true
        end
      end

      it "returns true when all subfields are displayed" do
        _(field.display?({:a => 1, :b => 2})).must_equal true
      end

      it "returns true when at least one or the subfields is displayed" do
        _(field.display?({:a => 1})).must_equal true
      end

      it "returns false when none of the subfieldsis displayed" do
        _(field.display?({:c => 3})).must_equal false
      end

      it "returns false when the value is empty hash" do
        _(field.display?({})).must_equal false
      end

      it "returns false when the value is nil" do
        _(field.display?(nil)).must_equal false
      end
    end

  end
end
