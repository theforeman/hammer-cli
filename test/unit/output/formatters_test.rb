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

  it "has features" do
    formatter.required_features.must_be_kind_of Array
  end

  it "should know if it has matching features" do
    formatter.stubs(:required_features).returns([:feature])
    formatter.match?([:feature]).must_equal true
    formatter.match?([:nofeature]).must_equal false
  end
end

describe HammerCLI::Output::Formatters::FormatterContainer do

  class TestFormatter
    def format(data, field_params={})
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
  let(:formatter) { HammerCLI::Output::Formatters::ListFormatter.new }

  it "serializes the value" do
    formatter.format([1, 2]).must_equal '1, 2'
  end

  it "returns empty string when the input is nil" do
    formatter.format(nil).must_equal ''
  end

  it "returns string value when the input is not a list" do
    formatter.format('some string').must_equal 'some string'
  end

  it 'can put the string on a new line' do
    formatter.format([1, 2], :on_new_line => true).must_equal "\n  1, 2"
  end

  it 'allows to change the separator' do
    formatter.format([1, 2, 3], :separator => '#').must_equal "1#2#3"
  end

  it 'can format list vertically' do
    expected_output = [
      '',
      '  value 1',
      '  value 2',
    ].join("\n")

    formatter.format(['value 1', 'value 2'], :separator => "\n", :on_new_line => true).must_equal expected_output
  end
end


describe HammerCLI::Output::Formatters::KeyValueFormatter do

  let(:params) {
    {
      :name => "Name",
      "value" => "Value",
    }
  }

  it "serializes the value" do
    formatter = HammerCLI::Output::Formatters::KeyValueFormatter.new
    formatter.format(params).must_equal 'Name => Value'
  end

  it "returns empty string when the input is nil" do
    formatter = HammerCLI::Output::Formatters::KeyValueFormatter.new
    formatter.format(nil).must_equal ''
  end

  it "returns empty string value when the input is not a hash" do
    formatter = HammerCLI::Output::Formatters::KeyValueFormatter.new
    formatter.format('some string').must_equal ''
  end
end



describe HammerCLI::Output::Formatters::LongTextFormatter do

  it "prepends new line" do
    formatter = HammerCLI::Output::Formatters::LongTextFormatter.new
    formatter.format("Some\nmultiline\ntext").must_equal "\n  Some\n  multiline\n  text"
  end

  it "accepts nil" do
    formatter = HammerCLI::Output::Formatters::LongTextFormatter.new
    formatter.format(nil).must_equal "\n  "
  end

  it "enables to switch indentation off" do
    formatter = HammerCLI::Output::Formatters::LongTextFormatter.new(:indent => false)
    formatter.format("Some\nmultiline\ntext").must_equal "\nSome\nmultiline\ntext"
  end

end

describe HammerCLI::Output::Formatters::InlineTextFormatter do
  let(:formatter) { HammerCLI::Output::Formatters::InlineTextFormatter.new }

  it 'prints multiline text to one line' do
    formatter.format("Some\nmultiline\ntext").must_equal('Some multiline text')
  end

  it 'accepts nil' do
    formatter.format(nil).must_equal('')
  end
end

describe HammerCLI::Output::Formatters::MultilineTextFormatter do
  let(:formatter) { HammerCLI::Output::Formatters::MultilineTextFormatter.new }
  let(:multiline_text) { "Some\nmultiline\ntext" }
  let(:indentation) { "\n    " }
  let(:long_multiline_text) { 'Lorem ipsum dolor' * 5 }

  it 'prints multiline text' do
    formatter.format(multiline_text).must_equal(
      "#{indentation}Some#{indentation}multiline#{indentation}text"
    )
  end

  it 'accepts nil' do
    formatter.format(nil).must_equal(indentation)
  end

  it 'accepts field width param' do
    formatter.format(long_multiline_text, width: 80)
             .must_equal(indentation + long_multiline_text[0..-6] +
                         indentation + long_multiline_text[-5..-1])
  end

  it 'deals with strange params' do
    formatter.format(long_multiline_text, width: -1)
             .must_equal(indentation + long_multiline_text[0..-26] +
                         indentation + long_multiline_text[-25..-1])
    formatter.format(long_multiline_text, width: 999)
             .must_equal(indentation + long_multiline_text)
  end
end

describe HammerCLI::Output::Formatters::BooleanFormatter do

  let(:formatter) { HammerCLI::Output::Formatters::BooleanFormatter.new }

  it "says yes for true like objects" do
    formatter.format(true).must_equal "yes"
    formatter.format("yes").must_equal "yes"
    formatter.format("no").must_equal "yes"
    formatter.format(1).must_equal "yes"
  end

  it "says no for false, nil, empty string and 0" do
    formatter.format(nil).must_equal "no"
    formatter.format(false).must_equal "no"
    formatter.format("").must_equal "no"
    formatter.format(0).must_equal "no"
  end
end
