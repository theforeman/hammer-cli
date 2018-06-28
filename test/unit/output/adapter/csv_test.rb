require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::CSValues do

  let(:adapter) { HammerCLI::Output::Adapter::CSValues.new }

  it "forbids default pagination" do
    adapter.paginate_by_default?.must_equal false
  end

  context "print_collection" do

    let(:field_name) { Fields::Field.new(:path => [:name], :label => "Name") }
    let(:field_started_at) { Fields::Field.new(:path => [:started_at], :label => "Started At") }
    let(:field_login) { Fields::Field.new(:path => [:login], :label => "Login") }
    let(:field_missing) { Fields::Field.new(:path => [:missing], :label => "Missing", :hide_missing => false) }
    let(:fields) {
      [field_name, field_started_at]
    }
    let(:data) { HammerCLI::Output::RecordCollection.new [{
      :name => "John Doe",
      :started_at => "2000"
    }]}

    it "should print column name" do
      out, err = capture_io { adapter.print_collection(fields, data) }
      out.must_match /.*Name,Started At.*/
      err.must_match //
    end

    it "should print field value" do
      out, err = capture_io { adapter.print_collection(fields, data) }
      out.must_match /.*John Doe.*/
      err.must_match //
    end

    it "does not print fields which data are missing from api by default" do
      fields << field_login
      out, err = capture_io { adapter.print_collection(fields, data) }
      out.wont_match /.*Login.*/
      err.must_match //
    end

    it "prints fields which data are missing from api when field has hide_missing flag set to false" do
      fields << field_missing
      out, err = capture_io { adapter.print_collection(fields, data) }
      out.must_match /.*Missing.*/
      err.must_match //
    end

    context "handle ids" do
      let(:field_id) { Fields::Id.new(:path => [:some_id], :label => "Id") }
      let(:fields) {
        [field_name, field_id]
      }
      let(:data) { HammerCLI::Output::RecordCollection.new [{
        :name => "John Doe",
        :some_id => "2000"
      }]}

      it "should ommit column of type Id by default" do
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.wont_match(/.*Id.*/)
        out.wont_match(/.*2000,.*/)
      end

      it "should print column of type Id when --show-ids is set" do
        adapter = HammerCLI::Output::Adapter::CSValues.new( { :show_ids => true } )
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*Id.*/)
      end
    end

    context "handle headers" do
      let(:empty_data) { HammerCLI::Output::RecordCollection.new [] }

      it "should print headers by default" do
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*Name.*/)
      end

      it "should print headers by default even if there is no data" do
        out, err = capture_io { adapter.print_collection(fields, empty_data) }
        out.must_match(/.*Name.*/)
      end

      it "should print data only when --no-headers is set" do
        expected_output = [
                           "John Doe,2000",
                           "",
                          ].join("\n")
        adapter = HammerCLI::Output::Adapter::CSValues.new( { :no_headers => true } )
        proc { adapter.print_collection(fields, data) }.must_output(expected_output)
      end

      it "should print nothing when --no-headers is set but no data" do
        expected_output = "\n"
        adapter = HammerCLI::Output::Adapter::CSValues.new( { :no_headers => true } )
        proc { adapter.print_collection(fields, empty_data) }.must_output(expected_output)
      end
    end

    context "handle fields with containers" do
      let(:demographics) {
        Fields::Label.new(:path => [], :label => "Demographics") do
          from :demographics do
            field :age, "Age"
            field :gender, "Gender"
            label _("Biometrics") do
              from :biometrics do
                field :weight, "Weight"
                field :height, "Height"
              end
            end
          end
        end
      }
      let(:fields) {
        [field_name, field_started_at, demographics]
      }
      let(:data) { HammerCLI::Output::RecordCollection.new [{
        :name => "John Doe",
        :started_at => "2000",
        :demographics=> { :age => '22', :gender => 'm',
                          :biometrics => { :weight => '123', :height => '155' } }
      }]}

      it "should print column names" do
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match /.*Demographics::Age,Demographics::Gender,Biometrics::Weight,Biometrics::Height*/
        err.must_match //
      end

      it "should print data" do
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match /.*2000,22,m,123,155*/
        err.must_match //
      end
    end

    context "handle fields with collections" do
      let(:items) {
        Fields::Collection.new(:path => [:items], :label => "Items") do
          from :item do
            field :name, "Item Name"
            field :quantity, "Item Quantity"
          end
        end
      }
      let(:fields) {
        [field_name, field_started_at, items]
      }
      let(:data) { HammerCLI::Output::RecordCollection.new [
        {
          :name => "John Doe",
          :started_at => "2000",
          :items => [{:item => { :name => 'hammer', :quantity => '100'}}]
        },
        {
          :name => "Jane Roe",
          :started_at => "2001",
          :items => [{:item => { :name => 'cleaver', :quantity => '1'}}, {:item => { :name => 'sledge', :quantity => '50'}}]
        }
      ]}

      it "should print collection column name" do
        out, err = capture_io { adapter.print_collection(fields, data) }

        lines = out.split("\n")
        lines[0].must_equal 'Name,Started At,Items::Item Name::1,Items::Item Quantity::1,Items::Item Name::2,Items::Item Quantity::2'

        err.must_match //
      end

      it "should print collection data" do
        out, err = capture_io { adapter.print_collection(fields, data) }
        lines = out.split("\n")

        lines[1].must_equal 'John Doe,2000,hammer,100,"",""'
        lines[2].must_equal 'Jane Roe,2001,cleaver,1,sledge,50'

        err.must_match //
      end

      it "should handle empty collection" do
        out, err = capture_io { adapter.print_collection(fields, []) }
        lines = out.split("\n")

        lines[0].must_equal 'Name,Started At,Items'

        err.must_match //
      end

    end

    context "formatters" do
      it "should apply formatters" do
        class DotFormatter < HammerCLI::Output::Formatters::FieldFormatter
          def format(data, field_params={})
            '-DOT-'
          end
        end

        adapter = HammerCLI::Output::Adapter::CSValues.new({}, { :Field => [ DotFormatter.new ]})
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*-DOT-.*/)
      end

      it "should not replace nil with empty string before it applies formatters" do
        class NilFormatter < HammerCLI::Output::Formatters::FieldFormatter
          def format(data, field_params={})
            'NIL' if data.nil?
          end
        end

        adapter = HammerCLI::Output::Adapter::CSValues.new({}, { :Field => [ NilFormatter.new ]})
        nil_data = HammerCLI::Output::RecordCollection.new [{ :name => nil }]
        out, err = capture_io { adapter.print_collection([field_name], nil_data) }
        out.must_match(/.*NIL.*/)
      end
    end

    context "output_stream" do

      let(:tempfile) { Tempfile.new("output_stream_csv_test_temp") }
      let(:context) { {:output_file => tempfile} }
      let(:adapter) { HammerCLI::Output::Adapter::CSValues.new(context, HammerCLI::Output::Output.formatters) }

      it "should not print to stdout when --output-file is set" do
        fields = [field_name]

        proc { adapter.print_collection(fields, data) }.must_output("")
      end

      it "should print to file if --output-file is set" do
        fields = [field_name]
        expected_output = "Name\nJohn Doe\n"

        adapter.print_collection(fields, data)
        tempfile.close
        IO.read(tempfile.path).must_equal(expected_output)
      end

    end

  end

  context "print message" do

    it "shoud print a message" do
      proc { adapter.print_message("SOME MESSAGE") }.must_output("Message\nSOME MESSAGE\n", "")
    end

    it "should print message, id and name of created/updated record" do
      proc {
        adapter.print_message("SOME MESSAGE", "id" => 83, "name" => "new_record")
      }.must_output("Message,Id,Name\nSOME MESSAGE,83,new_record\n", "")
    end

  end

end
