require File.join(File.dirname(__FILE__), 'test_helper')


describe String do

  context "formatting" do

    let(:str) { "AA%<a>s BB%<b>s" }
    let(:curly_str) { "AA%{a}s BB%{b}s" }
    let(:pos_str) { "AA%s BB%s" }

    it "should not fail without expected parameters" do
      str.format({}).must_equal 'AA BB'
    end

    it "should replace positional parameters" do
      pos_str.format(['A', 'B']).must_equal 'AAA BBB'
    end

    it "should replace named parameters" do
      str.format(:a => 'A', :b => 'B').must_equal 'AAA BBB'
    end

    it "should replace named parameters with string keys" do
      str.format('a' => 'A', 'b' => 'B').must_equal 'AAA BBB'
    end

    it "should replace named parameters marked with curly brackets" do
      curly_str.format(:a => 'A', :b => 'B').must_equal 'AAA BBB'
    end

  end


  context "camelize" do

    it "should camelize string with underscores" do
      "one_two_three".camelize.must_equal "OneTwoThree"
    end

    it "should not camelize string with dashes" do
      "one-two-three".camelize.must_equal "One-two-three"
    end

  end

  describe "indent" do

    it "indents single line string" do
      "line one".indent_with("  ").must_equal "  line one"
    end

    it "indents multi line string" do
      "line one\nline two".indent_with("  ").must_equal "  line one\n  line two"
    end

  end

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
      HammerCLI::interactive?.must_equal true
    end

    it "should by false when cli arg set" do
      HammerCLI::Settings.load({
        :ui => { :interactive => nil },
        :_params => { :interactive => false } })
      HammerCLI::interactive?.must_equal false
    end

    it "should by false when turned off in cfg" do
      HammerCLI::Settings.load({
        :ui => { :interactive => false },
        :_params => { :interactive => nil } })
      HammerCLI::interactive?.must_equal false
    end
  end

end

