require File.join(File.dirname(__FILE__), 'test_helper')


module Constant
  module Test
    class X
    end
  end
end

describe String do
  context 'formatting' do
    let(:str) { 'AA%<a>s BB%<b>s' }
    let(:curly_str) { 'AA%{a} BB%{b}' }
    let(:pos_str) { 'AA%s BB%s' }
    let(:str_with_percent) { 'Error: AA%<a>s BB%<b>s <%# template error %> verify this %>' }

    it 'should not fail without expected parameters' do
      _(str.format({})).must_equal 'AA BB'
    end
    it 'should replace positional parameters' do
      _(pos_str.format(['A', 'B'])).must_equal 'AAA BBB'
    end
    it 'should replace named parameters' do
      _(str.format(:a => 'A', :b => 'B')).must_equal 'AAA BBB'
    end
    it 'should replace named parameters with string keys' do
      _(str.format('a' => 'A', 'b' => 'B')).must_equal 'AAA BBB'
    end
    it 'should replace named parameters marked with curly brackets' do
      _(curly_str.format(:a => 'A', :b => 'B')).must_equal 'AAA BBB'
    end
    it 'should not fail due to presence of percent chars in string' do
      _(str_with_percent.format({})).must_equal 'Error: AA BB <%# template error %> verify this %>'
    end
    it 'should consider false values' do
      _(curly_str.format(:a => false, 'b' => false)).must_equal 'AAfalse BBfalse'
    end
  end

  context "camelize" do

    it "should camelize string with underscores" do
      _("one_two_three".camelize).must_equal "OneTwoThree"
    end

    it "should not camelize string with dashes" do
      _("one-two-three".camelize).must_equal "One-two-three"
    end

  end


  describe "underscore" do

    it "converts camelized string to underscore" do
      _("OneTwoThree".underscore).must_equal "one_two_three"
    end

    it "converts full class path name to underscore with slashes" do
      _("HammerCLI::SomeClass".underscore).must_equal "hammer_cli/some_class"
    end

    it "converts dashes to underscores" do
      _("Re-Read".underscore).must_equal "re_read"
    end

  end

  describe "indent" do

    it "indents single line string" do
      _("line one".indent_with("  ")).must_equal "  line one"
    end

    it "indents multi line string" do
      _("line one\nline two".indent_with("  ")).must_equal "  line one\n  line two"
    end

  end

  describe "constantize" do

    it "raises NameError for empty string" do
      _{
        "".constantize
      }.must_raise NameError
    end

    it "raises NameError for unknown constant" do
      _{
        "UnknownClass".constantize
      }.must_raise NameError
    end

    it "returns correct constant" do
      _("Object".constantize).must_equal Object
    end

    it "returns correct namespaced constant" do
      _("Constant::Test::X".constantize).must_equal Constant::Test::X
    end
  end

end

describe Hash do
  context 'transform_keys' do
    let(:original_hash) { { :one => 'one', :two => 'two', 'three' => 3 } }
    let(:transformed_hash) { { :ONE => 'one', :TWO => 'two', 'THREE' => 3 } }
    it 'should return a new hash with new keys' do
      new_hash = original_hash.transform_keys(&:upcase)
      _(new_hash).must_equal transformed_hash
    end
  end
end

describe HammerCLI do

  describe "interactive?" do

    before :each do
      @tty = STDOUT.tty?
      STDOUT.stubs(:'tty?').returns(true)
    end

    after :each do
      STDOUT.stubs(:'tty?').returns(@tty)
    end

    it "should be true when called in tty" do
      HammerCLI::Settings.load({
        :ui => { :interactive => nil },
        :_params => { :interactive => nil } })
      _(HammerCLI::interactive?).must_equal true
    end

    it "should by false when cli arg set" do
      HammerCLI::Settings.load({
        :ui => { :interactive => nil },
        :_params => { :interactive => false } })
      _(HammerCLI::interactive?).must_equal false
    end

    it "should by false when turned off in cfg" do
      HammerCLI::Settings.load({
        :ui => { :interactive => false },
        :_params => { :interactive => nil } })
      _(HammerCLI::interactive?).must_equal false
    end
  end


  describe "constant_path" do

    it "returns empty array for empty string" do
      _(HammerCLI.constant_path("")).must_equal []
    end

    it "raises NameError for unknown constant" do
      _{
        HammerCLI.constant_path("UnknownClass")
      }.must_raise NameError
    end

    it "returns single constant" do
      _(HammerCLI.constant_path("Object")).must_equal [Object]
    end

    it "returns correct path for namespaced constant" do
      _(HammerCLI.constant_path("Constant::Test::X")).must_equal [Constant, Constant::Test, Constant::Test::X]
    end
  end

  describe 'insert_relative' do
    let(:arr) { [:a, :b, :c] }

    it 'appends' do
      HammerCLI.insert_relative(arr, :append, nil, 1, 2, 3)
      assert_equal(arr, [:a, :b, :c, 1, 2, 3])
    end

    it 'prepends' do
      HammerCLI.insert_relative(arr, :prepend, nil, 1, 2, 3)
      assert_equal(arr, [1, 2, 3, :a, :b, :c])
    end

    it 'inserts after index' do
      HammerCLI.insert_relative(arr, :after, 1, 1, 2, 3)
      assert_equal(arr, [:a, :b, 1, 2, 3, :c])
    end

    it 'inserts before index' do
      HammerCLI.insert_relative(arr, :before, 1, 1, 2, 3)
      assert_equal(arr, [:a, 1, 2, 3, :b, :c])
    end
  end
end
