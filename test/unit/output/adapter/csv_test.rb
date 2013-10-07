require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::CSValues do

  let(:adapter) { HammerCLI::Output::Adapter::CSValues.new }

  context "print_records" do

    let(:field_name) { Fields::DataField.new(:path => [:name], :label => "Name") }
    let(:field_started_at) { Fields::DataField.new(:path => [:started_at], :label => "Started At") }
    let(:fields) {
      [field_name, field_started_at]
    }
    let(:data) {[{
      :name => "John Doe",
      :started_at => "2000"
    }]}

    it "should print column name" do
      proc { adapter.print_records(fields, data) }.must_output(/.*Name,Started At.*/, "")
    end

    it "should print field value" do
      proc { adapter.print_records(fields, data) }.must_output(/.*John Doe.*/, "")
    end

    context "handle ids" do
      let(:field_id) { Fields::Id.new(:path => [:some_id], :label => "Id") }
      let(:fields) {
        [field_name, field_id]
      }

      it "should ommit column of type Id by default" do
        out, err = capture_io { adapter.print_records(fields, data) }
        out.wont_match(/.*Id.*/)
        out.wont_match(/.*John Doe,.*/)
      end

      it "should print column of type Id when --show-ids is set" do
        adapter = HammerCLI::Output::Adapter::CSValues.new( { :show_ids => true } )
        out, err = capture_io { adapter.print_records(fields, data) }
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
        out, err = capture_io { adapter.print_records(fields, data) }
        out.must_match(/.*-DOT-.*/)
      end
    end
  end

end
