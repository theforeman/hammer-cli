require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::CSValues do

  let(:adapter) { HammerCLI::Output::Adapter::CSValues.new }

  context "print_collection" do

    let(:field_name) { Fields::DataField.new(:path => [:name], :label => "Name") }
    let(:field_started_at) { Fields::DataField.new(:path => [:started_at], :label => "Started At") }
    let(:fields) {
      [field_name, field_started_at]
    }
    let(:data) { HammerCLI::Output::RecordCollection.new [{
      :name => "John Doe",
      :started_at => "2000"
    }]}


    it "should print column name" do
      proc { adapter.print_collection(fields, data) }.must_output(/.*Name,Started At.*/, "")
    end

    it "should print field value" do
      proc { adapter.print_collection(fields, data) }.must_output(/.*John Doe.*/, "")
    end

    context "handle ids" do
      let(:field_id) { Fields::Id.new(:path => [:some_id], :label => "Id") }
      let(:fields) {
        [field_name, field_id]
      }

      it "should ommit column of type Id by default" do
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.wont_match(/.*Id.*/)
        out.wont_match(/.*John Doe,.*/)
      end

      it "should print column of type Id when --show-ids is set" do
        adapter = HammerCLI::Output::Adapter::CSValues.new( { :show_ids => true } )
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*Id.*/)
      end
    end

    context "formatters" do
      it "should apply formatters" do
        class DotFormatter < HammerCLI::Output::Formatters::FieldFormatter
          def format(data)
            '-DOT-'
          end
        end

        adapter = HammerCLI::Output::Adapter::CSValues.new({}, { :DataField => [ DotFormatter.new ]})
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*-DOT-.*/)
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
