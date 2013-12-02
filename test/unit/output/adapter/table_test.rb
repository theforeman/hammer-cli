require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Table do

  let(:adapter) { HammerCLI::Output::Adapter::Table.new }

  context "print_collection" do

    let(:field_name) { Fields::DataField.new(:path => [:name], :label => "Name") }
    let(:fields) {
      [field_name]
    }
    let(:data) { HammerCLI::Output::RecordCollection.new [{
      :name => "John Doe"
    }]}

    it "should print column name " do
      proc { adapter.print_collection(fields, data) }.must_output(/.*NAME.*/, "")
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
        out.wont_match(/.*ID.*/)
      end

      it "should print column of type Id when --show-ids is set" do
        adapter = HammerCLI::Output::Adapter::Table.new( { :show_ids => true } )
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*ID.*/)
      end
    end

    context "formatters" do
      it "should apply formatters" do
        class DotFormatter < HammerCLI::Output::Formatters::FieldFormatter
          def format(data)
            '-DOT-'
          end
        end

        adapter = HammerCLI::Output::Adapter::Table.new({}, { :DataField => [ DotFormatter.new ]})
        out, err = capture_io { adapter.print_collection(fields, data) }
        out.must_match(/.*-DOT-.*/)
      end
    end
  end

end
