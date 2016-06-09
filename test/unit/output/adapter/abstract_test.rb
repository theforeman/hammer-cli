require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Output::Adapter::Abstract do

  let(:adapter_class) { HammerCLI::Output::Adapter::Abstract }
  let(:adapter) { HammerCLI::Output::Adapter::Abstract.new }


  it "should have tags" do
    adapter.tags.must_be_kind_of Array
  end

  class UnknownTestFormatter < HammerCLI::Output::Formatters::FieldFormatter
    def format(data, field_params={})
      data+'.'
    end

    def tags
      [:unknown]
    end
  end

  it "allows default pagination" do
    adapter.paginate_by_default?.must_equal true
  end

  it "should filter formatters with incompatible tags" do

    HammerCLI::Output::Formatters::FormatterLibrary.expects(:new).with({ :type => [] })
    adapter = adapter_class.new({}, {:type => [UnknownTestFormatter.new]})
  end

  it "should keep compatible formatters" do
    formatter = UnknownTestFormatter.new
    HammerCLI::Output::Formatters::FormatterLibrary.expects(:new).with({ :type => [formatter] })
    # set :unknown tag to abstract
    adapter_class.any_instance.stubs(:tags).returns([:unknown])
    adapter = adapter_class.new({}, {:type => [formatter]})
  end

  it "should put serializers first" do
    formatter1 = UnknownTestFormatter.new
    formatter1.stubs(:tags).returns([])
    formatter2 = UnknownTestFormatter.new
    formatter2.stubs(:tags).returns([:flat])
    HammerCLI::Output::Formatters::FormatterLibrary.expects(:new).with({ :type => [formatter2, formatter1] })
    # set :unknown tag to abstract
    adapter_class.any_instance.stubs(:tags).returns([:flat])
    adapter = adapter_class.new({}, {:type => [formatter1, formatter2]})
  end


  context "messages" do
    it "should print message to stdout" do
      proc { adapter.print_message("MESSAGE") }.must_output(/.*MESSAGE.*/, "")
    end

    it "should print formatted message with parameters" do
      proc { adapter.print_message("MESSAGE %{a}, %{b}", :a => 'A', :b => 'B') }.must_output(/.*MESSAGE A, B.*/, "")
    end

  end

  it "should raise not implemented on print_collection" do
    proc { adapter.print_collection([], HammerCLI::Output::RecordCollection.new([])) }.must_raise NotImplementedError
  end

  context "error messages" do
    it "should print error message to stderr" do
      proc { adapter.print_error("MESSAGE") }.must_output("", /.*MESSAGE.*/)
    end

    let(:expected_output) { "MESSAGE:\n"+
                            "  error\n"+
                            "  message\n"+
                            "  details\n"
    }

    let(:expected_formatted_output) { "MESSAGE A, B:\n"+
                                      "  error A\n"+
                                      "  error B\n"
    }

    it "should print list details of error to stderr" do
      proc { adapter.print_error("MESSAGE", ["error", "message", "details"]) }.must_output("", expected_output)
    end

    it "should print string details of error to stderr" do
      proc { adapter.print_error("MESSAGE", "error\nmessage\ndetails") }.must_output("", expected_output)
    end

    it "should print formatted message with parameters" do
      proc {
        adapter.print_error("MESSAGE %{a}, %{b}", ["error %{a}", "error %{b}"], :a => 'A', :b => 'B')
      }.must_output("", expected_formatted_output)
    end

  end

  context "test data_for_field" do
    let(:field) { Fields::Field.new(:path => [:field1]) }

    it "returns nil if the record is nil" do
      record = nil
      assert_nil adapter.send(:data_for_field, field, record)
    end

    it "returns nil if the record is not a hash" do
      record = []
      assert_nil adapter.send(:data_for_field, field, record)
    end

    it "returns nil, if the data does not exist for the field" do
      record = { :field2 => :value2 }
      assert_nil adapter.send(:data_for_field, field, record)
    end

    it "returns the value, if data exists for the field" do
      record = { :field1 => :value1, :field2 => :value2 }
      assert_equal adapter.send(:data_for_field, field, record), :value1
    end
  end
end
