require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Output::Formatters::FormatterLibrary do
  it "accepts formatter" do
    lib = HammerCLI::Output::Formatters::FormatterLibrary.new(
      :Id => HammerCLI::Output::Formatters::FieldFormatter.new)
    lib.formatter_for_type(Fields::Id).must_be_instance_of HammerCLI::Output::Formatters::FormatterContainer
  end

  it "can add formatter to instance" do
    lib = HammerCLI::Output::Formatters::FormatterLibrary.new
    lib.register_formatter :Id, HammerCLI::Output::Formatters::FieldFormatter.new
    lib.formatter_for_type(Fields::Id).must_be_instance_of HammerCLI::Output::Formatters::FormatterContainer
  end
end

describe HammerCLI::Output::Formatters::FieldFormatter do
  let(:formatter) { HammerCLI::Output::Formatters::FieldFormatter.new }
  it "has format method" do
    formatter.respond_to?(:format).must_equal true
  end

  it "has tags" do
    formatter.tags.must_be_kind_of Array
  end

  it "should know if it has matching tags" do
    formatter.stubs(:tags).returns([:tag])
    formatter.match?([:tag]).must_equal true
    formatter.match?([:notag]).must_equal false
  end
end

describe HammerCLI::Output::Formatters::FormatterContainer do

  class TestFormatter
    def format(data)
      data+'.'
    end
  end

  it "accepts formatter" do
    container = HammerCLI::Output::Formatters::FormatterContainer.new(TestFormatter.new)
    container.format('').must_equal '.'
  end
    
  it "has format method" do
    container = HammerCLI::Output::Formatters::FormatterContainer.new
    container.respond_to?(:format).must_equal true
  end

  it "can add formatter to instance" do
    container = HammerCLI::Output::Formatters::FormatterContainer.new(TestFormatter.new)
    container.add_formatter TestFormatter.new
    container.format('').must_equal '..'
  end
end

describe HammerCLI::Output::Formatters::ColorFormatter do
  it "colorizes the value" do
    formatter = HammerCLI::Output::Formatters::ColorFormatter.new(:red)
    formatter.format('red').must_equal "\e[31mred\e[0m"
  end
end

describe HammerCLI::Output::Formatters::DateFormatter do
  it "formats the date" do
    formatter = HammerCLI::Output::Formatters::DateFormatter.new
    formatter.format('2000-01-01 21:01:01').must_equal "2000/01/01 21:01:01"
  end

  it "returns empty string on wrong value" do
    formatter = HammerCLI::Output::Formatters::DateFormatter.new
    formatter.format('wrong value').must_equal ""
  end  
end

describe HammerCLI::Output::Formatters::ListFormatter do
  it "serializes the value" do
    formatter = HammerCLI::Output::Formatters::ListFormatter.new
    formatter.format([1, 2]).must_equal '1, 2'
  end
end
