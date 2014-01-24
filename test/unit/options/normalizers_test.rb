require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::Options::Normalizers do


  describe 'abstract' do

    let(:formatter) { HammerCLI::Options::Normalizers::AbstractNormalizer.new }

    it "should raise exception on format" do
      proc { formatter.format(nil) }.must_raise NotImplementedError
    end

  end

  describe 'list' do

    let(:formatter) { HammerCLI::Options::Normalizers::List.new }

    it "should return empty array on nil" do
      formatter.format(nil).must_equal []
    end

    it "should return empty array on empty string" do
      formatter.format("").must_equal []
    end

    it "should parse a string" do
      formatter.format("a").must_equal ['a']
    end

    it "should parse a comma separated string" do
      formatter.format("a,b,c").must_equal ['a', 'b', 'c']
    end
  end


  describe 'key_value_list' do

    let(:formatter) { HammerCLI::Options::Normalizers::KeyValueList.new }

    it "should return empty array on nil" do
      formatter.format(nil).must_equal({})
    end

    it "should return empty array on empty string" do
      formatter.format("").must_equal({})
    end

    it "should parse a string" do
      proc { formatter.format("a") }.must_raise ArgumentError
    end

    it "should parse a comma separated string" do
      formatter.format("a=1,b=2,c=3").must_equal({'a' => '1', 'b' => '2', 'c' => '3'})
    end

    it "should parse a comma separated string 2" do
      proc { formatter.format("a=1,b,c=3") }.must_raise ArgumentError
    end
  end

  describe 'bool' do

    let(:formatter) { HammerCLI::Options::Normalizers::Bool.new }

    it "should return true on true" do
      formatter.format("true").must_equal(true)
      formatter.format("TRUE").must_equal(true)
    end

    it "should return true on t" do
      formatter.format("t").must_equal(true)
      formatter.format("T").must_equal(true)
    end

    it "should return true on yes" do
      formatter.format("yes").must_equal(true)
      formatter.format("YES").must_equal(true)
    end

    it "should return true on y" do
      formatter.format("y").must_equal(true)
      formatter.format("Y").must_equal(true)
    end

    it "should return true on 1" do
      formatter.format("1").must_equal(true)
    end

    it "should return false on false" do
      formatter.format("false").must_equal(false)
      formatter.format("FALSE").must_equal(false)
    end

    it "should return false on f" do
      formatter.format("f").must_equal(false)
      formatter.format("F").must_equal(false)
    end

    it "should return false on no" do
      formatter.format("no").must_equal(false)
      formatter.format("NO").must_equal(false)
    end

    it "should return false on n" do
      formatter.format("n").must_equal(false)
      formatter.format("N").must_equal(false)
    end

    it "should return false on 0" do
      formatter.format("0").must_equal(false)
    end

    it "should raise exception on nil" do
      proc { formatter.format(nil) }.must_raise ArgumentError
    end

    it "should raise exception on other values" do
      proc { formatter.format('unknown') }.must_raise ArgumentError
    end
  end

  describe 'enum' do

    let(:formatter) { HammerCLI::Options::Normalizers::Enum.new ['a', 'b'] }

    it "should return return value when in the list" do
      formatter.format("a").must_equal("a")
    end

    it "should rise argument error when the value is nil" do
      proc { formatter.format(nil) }.must_raise ArgumentError
    end

    it "should rise argument error when the value is not in the list" do
      proc { formatter.format("c") }.must_raise ArgumentError
    end

    it "should list allowed values in description" do
      formatter.description.must_equal("One of 'a', 'b'")
    end

  end

  describe 'datetime' do

    let(:formatter) { HammerCLI::Options::Normalizers::DateTime.new }

    it "should raise argument error when the value is nil" do
      proc { formatter.format(nil) }.must_raise ArgumentError
    end

    it "should raise argument error when the value is not a date" do
      proc { formatter.format("not a date") }.must_raise ArgumentError
    end

    it "should accept and parse iso8601" do
      formatter.format("1986-01-01T08:30:20").must_equal("1986-01-01T08:30:20+00:00")
    end

    it "should accept and parse YYYY-MM-DD HH:MM:SS" do
      formatter.format("1986-01-01 08:30:20").must_equal("1986-01-01T08:30:20+00:00")
    end

    it "should accept and parse YYYY/MM/DD HH:MM:SS" do
      formatter.format("1986/01/01 08:30:20").must_equal("1986-01-01T08:30:20+00:00")
    end

  end

end

