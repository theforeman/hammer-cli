require File.join(File.dirname(__FILE__), '../test_helper')
require 'hammer_cli/csv_parser'

describe HammerCLI::CSVParser do

  describe 'parse' do
    let(:parser) { HammerCLI::CSVParser.new }

    it "parses nil" do
      parser.parse(nil).must_equal []
    end

    it "parses empty string" do
      parser.parse('').must_equal ['']
    end

    it "parses single value" do
      parser.parse('a').must_equal ['a']
    end

    it "parses a dquoted string" do
      parser.parse('\"a').must_equal ['"a']
    end

    it "parses a quoted string" do
      parser.parse("Mary\\'s").must_equal ["Mary's"]
    end

    it "should parse a comma separated string" do
      parser.parse("a,b,c").must_equal ['a', 'b', 'c']
    end

    it "parses a string with escaped comma" do
      parser.parse('a\,b,c').must_equal ['a,b', 'c']
    end

    it "should parse a comma separated string with quotes" do
      parser.parse('a,b,\\"c\\"').must_equal ['a', 'b', '"c"']
    end

    it "parses a comma separated string with values including comma" do
      parser.parse('a,b,"c,d"').must_equal ['a', 'b', 'c,d']
    end

    it "parses a comma separated string with values including comma (dquotes)" do
      parser.parse("a,b,'c,d'").must_equal ['a', 'b', 'c,d']
    end

    it "raises quoting error" do
      proc { parser.parse('1,"3,4""s') }.must_raise ArgumentError
    end
  end
end
