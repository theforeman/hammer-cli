require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Output::Output do

  let(:adapter) { HammerCLI::Output::Adapter::Silent }
  let(:definition) { HammerCLI::Output::Definition.new }

  let(:context) { { :adapter => :silent, :interactive => false } }
  let(:out_class) { HammerCLI::Output::Output }
  let(:out) { out_class.new(context) }

  context "messages" do

    let(:msg) { "Some message" }
    let(:details) { "Some\nmessage\ndetails" }
    let(:msg_arg) { {:a => 'A'} }

    it "prints info message via adapter" do
      adapter.any_instance.expects(:print_message).with(msg, {})
      out.print_message(msg)
    end

    it "prints info message via adapter with arguments" do
      adapter.any_instance.expects(:print_message).with(msg, msg_arg)
      out.print_message(msg, msg_arg)
    end

    it "prints error message via adapter" do
      adapter.any_instance.expects(:print_error).with(msg, nil, {})
      out.print_error(msg, nil)
    end

    it "prints error message via adapter with arguments" do
      adapter.any_instance.expects(:print_error).with(msg, nil, msg_arg)
      out.print_error(msg, nil, msg_arg)
    end

    it "prints error message with details via adapter" do
      adapter.any_instance.expects(:print_error).with(msg, details, {})
      out.print_error(msg, details)
    end

    it "prints error message from exception via adapter" do
      adapter.any_instance.expects(:print_error).with(msg, nil, {})
      out.print_error(Exception.new(msg), nil)
    end
  end

  context "data" do

    let(:item1) { {} }
    let(:item2) { {} }
    let(:collection) { [item1, item2] }

    it "prints single resource" do
      adapter.any_instance.expects(:print_record).with([], item1)
      out.print_record(definition, item1)
    end

    it "prints single resource as collection" do
      adapter.any_instance.expects(:print_collection).with([], instance_of(HammerCLI::Output::RecordCollection), {})
      out.print_collection(definition, item1)
    end


    it "prints array of resources" do
      adapter.any_instance.expects(:print_collection).with([], instance_of(HammerCLI::Output::RecordCollection), {})
      out.print_collection(definition, collection)
    end

    it "prints recordset" do
      data = HammerCLI::Output::RecordCollection.new(collection)
      adapter.any_instance.expects(:print_collection).with([], data, {})
      out.print_collection(definition, data)
    end

  end

  context "adapters" do
    it "should register adapter" do
      out_class.register_adapter(:test, HammerCLI::Output::Adapter::Silent)
      _(out_class.adapters[:test]).must_equal(HammerCLI::Output::Adapter::Silent)
    end

    it "should return required default adapter" do
      out = out_class.new({}, {:default_adapter => :silent})
      _(out.adapter).must_be_instance_of HammerCLI::Output::Adapter::Silent
    end

    it "should use adapter form context" do
      out = out_class.new({:adapter => :silent})
      _(out.adapter).must_be_instance_of HammerCLI::Output::Adapter::Silent
    end

    it "should prioritize adapter from the context" do
      out = out_class.new({:adapter => :table}, {:default_adapter => :silent})
      _(out.adapter).must_be_instance_of HammerCLI::Output::Adapter::Table
    end

    it "should use base adapter if the requested default was not found" do
      out = out_class.new({}, {:default_adapter => :unknown})
      _(out.adapter).must_be_instance_of HammerCLI::Output::Adapter::Base
    end
  end

  context "formatters" do
    it "should register formatter" do
      formatter = HammerCLI::Output::Formatters::FieldFormatter.new
      out_class.register_formatter(formatter, :type1, :type2)
      _(out_class.formatters[:type1]).must_equal([formatter])
      _(out_class.formatters[:type2]).must_equal([formatter])
    end
  end

  describe 'verbosity' do
    let(:msg) { "Some message\n" }
    let(:quiet_opts)        { { :verbosity => HammerCLI::V_QUIET } }
    let(:no_verbose_opts)   { { :verbosity => HammerCLI::V_UNIX } }
    let(:verbose_opts)      { { :verbosity => HammerCLI::V_VERBOSE } }
    let(:very_verbose_opts) { { :verbosity => HammerCLI::V_VERBOSE + 1 } }
    let(:data) do
      HammerCLI::Output::RecordCollection.new(
        [{
          :id => 112,
          :name => 'John',
          :surname => 'Doe'
        }]
      )
    end
    let(:id)         { Fields::Id.new(:path => [:id], :label => 'Id') }
    let(:firstname)  { Fields::Field.new(:path => [:name], :label => 'Name') }
    let(:surname)    { Fields::Field.new(:path => [:surname], :label => 'Surname') }
    let(:definition) { HammerCLI::Output::Definition.new }
    let(:expected_record_output) do
      [
        "Name:    John",
        "Surname: Doe",
        "\n"
      ].join("\n")
    end

    context 'quiet' do
      let(:context) { quiet_opts }
      let(:output) { HammerCLI::Output::Output.new(context) }

      it 'should not print info messages with higher verbosity level' do
        assert_output('', nil) do
          output.print_message(msg)
        end
        assert_output('', nil) do
          output.print_message(msg, {}, no_verbose_opts)
        end
        assert_output('', nil) do
          output.print_message(msg, {}, verbose_opts)
        end
      end

      it 'should print message with lower or equal verbosity level' do
        assert_output(msg, nil) do
          output.print_message(msg, {}, quiet_opts)
        end
      end

      it 'should print error message even when hammer verbosity is level 0' do
        assert_output(nil, msg) do
          output.print_error(msg)
        end
      end

      it 'should not print error messages with higher verbosity level' do
        assert_output(nil, '') do
          output.print_error(msg, nil, {}, verbose_opts)
        end
      end

      it 'should not print record data' do
        definition.append([id, firstname, surname])
        assert_output('', nil) do
          output.print_record(definition, data.first)
        end
      end

      it 'should not print collection data' do
        definition.append([id, firstname, surname])
        assert_output('', nil) do
          output.print_record(definition, data)
        end
      end
    end

    context 'no-verbose' do
      let(:context) { no_verbose_opts }
      let(:output) { HammerCLI::Output::Output.new(context) }

      it 'should not print info messages with higher verbosity level' do
        assert_output('', nil) do
          output.print_message(msg)
        end
        assert_output('', nil) do
          output.print_message(msg, {}, verbose_opts)
        end
      end

      it 'should print message with lower or equal verbosity level' do
        assert_output(msg, nil) do
          output.print_message(msg, {}, quiet_opts)
        end
        assert_output(msg, nil) do
          output.print_message(msg, {}, no_verbose_opts)
        end
      end

      it 'should print error message' do
        assert_output(nil, msg) do
          output.print_error(msg)
        end
      end

      it 'should not print error messages with higher verbosity level' do
        assert_output(nil, '') do
          output.print_error(msg, nil, {}, verbose_opts)
        end
      end

      it 'should print record data' do
        definition.append([id, firstname, surname])
        assert_output(expected_record_output, nil) do
          output.print_record(definition, data.first)
        end
      end

      it 'should print collection data' do
        definition.append([id, firstname, surname])
        assert_output(expected_record_output, nil) do
          output.print_record(definition, data)
        end
      end
    end

    context 'verbose' do
      let(:context) { verbose_opts }
      let(:output) { HammerCLI::Output::Output.new(context) }
      it 'should not print info messages with higher verbosity level' do
        assert_output('', nil) do
          output.print_message(msg, {}, very_verbose_opts)
        end
      end

      it 'should print message with lower or equal verbosity level' do
        assert_output(msg, nil) do
          output.print_message(msg, {}, quiet_opts)
        end
        assert_output(msg, nil) do
          output.print_message(msg, {}, no_verbose_opts)
        end
        assert_output(msg, nil) do
          output.print_message(msg, {}, verbose_opts)
        end
      end

      it 'should print error message' do
        assert_output(nil, msg) do
          output.print_error(msg)
        end
      end

      it 'should not print error messages with higher verbosity level' do
        assert_output(nil, '') do
          output.print_error(msg, nil, {}, very_verbose_opts)
        end
      end

      it 'should print record data' do
        definition.append([id, firstname, surname])
        assert_output(expected_record_output, nil) do
          output.print_record(definition, data.first)
        end
      end

      it 'should print collection data' do
        definition.append([id, firstname, surname])
        assert_output(expected_record_output, nil) do
          output.print_record(definition, data)
        end
      end
    end
  end
end
