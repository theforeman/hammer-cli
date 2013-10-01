require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Output::Output do


  before :each do
    @adapter = HammerCLI::Output::Adapter::Silent

    @definition = HammerCLI::Output::Definition.new

    @out = HammerCLI::Output::Output
  end

  context "messages" do

    let(:msg) { "Some message" }
    let(:details) { "Some\nmessage\ndetails" }

    it "prints info message via adapter" do
      @adapter.any_instance.expects(:print_message).with(msg)
      @out.print_message(msg, {}, { :adapter => :silent })
    end

    it "prints error message via adapter" do
      @adapter.any_instance.expects(:print_error).with(msg, nil)
      @out.print_error(msg, nil, {}, { :adapter => :silent })
    end

    it "prints error message with details via adapter" do
      @adapter.any_instance.expects(:print_error).with(msg, details)
      @out.print_error(msg, details, {}, { :adapter => :silent })
    end

    it "prints error message from exception via adapter" do
      @adapter.any_instance.expects(:print_error).with(msg, nil)
      @out.print_error(Exception.new(msg), nil, {}, { :adapter => :silent })
    end
  end

  context "data" do

    let(:item1) { {} }
    let(:item2) { {} }
    let(:collection) { [item1, item2] }

    it "prints single resource" do
      @adapter.any_instance.expects(:print_records).with([], [{}])
      @out.print_records(@definition, item1, {}, { :adapter => :silent })
    end

    it "prints array of resources" do
      @adapter.any_instance.expects(:print_records).with([], collection)
      @out.print_records(@definition, collection, {}, { :adapter => :silent })
    end

  end

  context "adapters" do
    it "should register adapter" do
      @out.register_adapter(:test, HammerCLI::Output::Adapter::Silent)
      @out.adapters[:test].must_equal(HammerCLI::Output::Adapter::Silent)
    end

    it "should return requested adapter" do
      @out.adapter(:silent, {}).must_be_instance_of HammerCLI::Output::Adapter::Silent
    end

    it "should return requested adapter with priority for context" do
      @out.adapter(:silent, {:adapter => :table}).must_be_instance_of HammerCLI::Output::Adapter::Table
    end

    it "should return requested adapter with fallback to base" do
      @out.adapter(:unknown, {}).must_be_instance_of HammerCLI::Output::Adapter::Base
    end
  end

  context "formatters" do
    it "should register formatter" do
      formatter = HammerCLI::Output::Formatters::FieldFormatter.new
      @out.register_formatter(formatter, :type1, :type2)
      @out.formatters[:type1].must_equal([formatter])
      @out.formatters[:type2].must_equal([formatter])
    end
  end

end

