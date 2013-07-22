require_relative '../test_helper'

describe HammerCLI::Output::Output do


  before :each do
    @adapter = HammerCLI::Output::Adapter::Silent

    @definition = HammerCLI::Output::Definition.new

    @interpreter = HammerCLI::Output::DefinitionInterpreter.new :definition => @definition
    @interpreter.stubs(:fields).returns(:fields)

    @out = HammerCLI::Output::Output.new :adapter => @adapter,
                                      :interpreter => @interpreter,
                                      :definition => @definition
  end

  context "dependency injection" do

    let(:fake) { Object.new }

    it "should assign interpreter" do
      @out.interpreter.must_equal @interpreter
    end

    it "should assign definition" do
      @out.definition.must_equal @definition
    end

    it "should assign adapter" do
      @out.adapter.must_equal @adapter
    end

    context "default instances" do

      let(:new_instance) { HammerCLI::Output::Output.new }

      it "interpreter" do
        new_instance.interpreter.must_be_instance_of HammerCLI::Output::DefinitionInterpreter
      end

      it "definition" do
        new_instance.definition.must_be_instance_of HammerCLI::Output::Definition
      end

      it "adapter" do
        new_instance.adapter.must_be_instance_of HammerCLI::Output::Adapter::Base
      end
    end
  end

  context "messages" do

    let(:msg) { "Some message" }
    let(:details) { "Some\nmessage\ndetails" }

    it "prints info message via adapter" do
      @adapter.expects(:print_message).with(msg)
      @out.print_message(msg)
    end

    it "prints error message via adapter" do
      @adapter.expects(:print_error).with(msg, nil)
      @out.print_error(msg)
    end

    it "prints error message with details via adapter" do
      @adapter.expects(:print_error).with(msg, details)
      @out.print_error(msg, details)
    end

    it "prints error message from exception via adapter" do
      @adapter.expects(:print_error).with(msg, nil)
      @out.print_error(Exception.new(msg))
    end
  end

  context "data" do

    let(:heading) { "Some Heading" }
    let(:item1) { {} }
    let(:item2) { {} }
    let(:collection) { [item1, item2] }

    context "prints single resource" do
      it "without header" do
        @adapter.expects(:print_records).with(:fields, [item1], nil)
        @out.print_records(item1)
      end
      it "with header" do
        @adapter.expects(:print_records).with(:fields, [item1], heading)
        @out.print_records(item1, heading)
      end
    end

    context "prints array of resources" do
      it "without header" do
        @adapter.expects(:print_records).with(:fields, collection, nil)
        @out.print_records(collection)
      end
      it "with header" do
        @adapter.expects(:print_records).with(:fields, collection, heading)
        @out.print_records(collection, heading)
      end
    end

  end

end

