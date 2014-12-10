require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::Options::Matcher do

  let(:option_a1) { Clamp::Option::Definition.new("--opt_a1", "OPT_A", "some option") }
  let(:option_a2) { Clamp::Option::Definition.new("--opt_a2", "OPT_A", "some option") }
  let(:option_a3) { Clamp::Option::Definition.new("--opt_a3", "OPT_A", "some option") }
  let(:option_b1) { Clamp::Option::Definition.new("--opt_b1", "OPT_B", "some option") }

  it "tests value" do
    matcher = HammerCLI::Options::Matcher.new(
      :long_switch => '--opt_a1'
    )
    matcher.matches?(option_a1).must_equal true
    matcher.matches?(option_a2).must_equal false
  end

  it "tests regex" do
    matcher = HammerCLI::Options::Matcher.new(
      :long_switch => /--opt_a.*/
    )
    matcher.matches?(option_a1).must_equal true
    matcher.matches?(option_a2).must_equal true
    matcher.matches?(option_b1).must_equal false
  end

  it "tests multiple conditions" do
    matcher = HammerCLI::Options::Matcher.new(
      :long_switch => /--opt_.1/,
      :type => 'OPT_A'
    )
    matcher.matches?(option_a1).must_equal true
    matcher.matches?(option_a2).must_equal false
    matcher.matches?(option_a3).must_equal false
    matcher.matches?(option_b1).must_equal false
  end

  it "tests multiple values or regexes" do
    matcher = HammerCLI::Options::Matcher.new(
      :long_switch => [/--opt_.1/, "--opt_a3"]
    )
    matcher.matches?(option_a1).must_equal true
    matcher.matches?(option_a2).must_equal false
    matcher.matches?(option_a3).must_equal true
    matcher.matches?(option_b1).must_equal true
  end

  it "tests nil for unknown methods" do
    matcher = HammerCLI::Options::Matcher.new(
      :unknown_method => "some value"
    )
    matcher.matches?(option_a1).must_equal false

    matcher = HammerCLI::Options::Matcher.new(
      :unknown_method => nil
    )
    matcher.matches?(option_a1).must_equal true
  end

end
