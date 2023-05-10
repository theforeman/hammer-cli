require 'hammer_cli/options/validators/dsl_block_validator'
require_relative '../../test_helper'

describe "constraints" do
  let(:option_values) {{
    :option_a => 1,
    :option_b => 1,
    'option_c' => 1,
    :option_unset_d => nil,
    :option_unset_e => nil
  }}

  let(:option_names) { ["a", "b", "c", "unset-d", "unset-e", "default"] }
  let(:options) {
    option_names.collect{ |n| Clamp::Option::Definition.new(["-"+n, "--option-"+n], n.upcase, "Option "+n.upcase) }
  }

  describe HammerCLI::Options::Validators::DSL::BaseConstraint do

    let(:cls) { HammerCLI::Options::Validators::DSL::BaseConstraint }

    describe "exist?" do
      it "throws not implemented error" do
        constraint = cls.new(options, option_values, [:option_a, :option_b, :option_c])
        _{ constraint.exist? }.must_raise NotImplementedError
      end
    end

    describe "rejected" do
      it "should raise exception when exist? returns true" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(true)
        _{ constraint.rejected }.must_raise HammerCLI::Options::Validators::ValidationError
      end

      it "should raise exception with a message" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(true)
        begin
          constraint.rejected :msg => "CUSTOM MESSAGE"
        rescue HammerCLI::Options::Validators::ValidationError => e
          _(e.message).must_equal "CUSTOM MESSAGE"
        end
      end

      it "should return nil when exist? returns true" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(false)
        assert_nil constraint.rejected
      end
    end

    describe "required" do
      it "should raise exception when exist? returns true" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(false)
        _{ constraint.required }.must_raise HammerCLI::Options::Validators::ValidationError
      end

      it "should raise exception with a message" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(false)
        begin
          constraint.rejected :msg => "CUSTOM MESSAGE"
        rescue HammerCLI::Options::Validators::ValidationError => e
          _(e.message).must_equal "CUSTOM MESSAGE"
        end
      end

      it "should return nil when exist? returns true" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(true)
        assert_nil constraint.required
      end
    end

  end

  describe HammerCLI::Options::Validators::DSL::AllConstraint do

    let(:cls) { HammerCLI::Options::Validators::DSL::AllConstraint }

    describe "exist?" do

      it "should return true when no options are passed" do
        constraint = cls.new(options, option_values, [])
        _(constraint.exist?).must_equal true
      end

      it "should return true when all the options exist" do
        constraint = cls.new(options, option_values, [:option_a, :option_b, :option_c])
        _(constraint.exist?).must_equal true
      end

      it "should return false when one of the options is missing" do
        constraint = cls.new(options, option_values, [:option_a, :option_b, :option_c, :option_unset_d])
        _(constraint.exist?).must_equal false
      end
    end

  end

  describe HammerCLI::Options::Validators::DSL::OneOptionConstraint do
    let(:cls) { HammerCLI::Options::Validators::DSL::OneOptionConstraint }

    describe "exist?" do
      it "should return true when the option exist" do
        constraint = cls.new(options, option_values, :option_a)
        _(constraint.exist?).must_equal true
      end

      it "should return false when the option is missing" do
        constraint = cls.new(options, option_values, :option_unset_d)
        _(constraint.exist?).must_equal false
      end
    end

    describe "#rejected" do
      it "returns nil when the option is missing" do
        constraint = cls.new(options, option_values, :option_unset_d)
        assert_nil constraint.rejected
      end

      it "raises exception when the option is present" do
        constraint = cls.new(options, option_values, :option_a)
        e = _{ constraint.rejected }.must_raise HammerCLI::Options::Validators::ValidationError
        _(e.message).must_equal "You can't set option --option-a."
      end
    end

    describe "#required" do
      it "returns nil when the option exist" do
        constraint = cls.new(options, option_values, :option_a)
        assert_nil constraint.required
      end

      it "raises exception when the option is present" do
        constraint = cls.new(options, option_values, :option_unset_d)
        e = _{ constraint.required }.must_raise HammerCLI::Options::Validators::ValidationError
        _(e.message).must_equal 'Option --option-unset-d is required.'
      end
    end

    describe "#value" do
      it "returns value of the option" do
        constraint = cls.new(options, option_values, :option_a)
        _(constraint.value).must_equal 1
      end

      it "returns nil when the option is missing" do
        constraint = cls.new(options, option_values, :option_unset_d)
        assert_nil constraint.value
      end
    end
  end

  describe HammerCLI::Options::Validators::DSL::AnyConstraint do

    let(:cls) { HammerCLI::Options::Validators::DSL::AnyConstraint }

    describe "exist?" do

      it "should return true when no options are passed" do
        constraint = cls.new(options, option_values, [])
        _(constraint.exist?).must_equal true
      end

      it "should return true when one of the options exist" do
        constraint = cls.new(options, option_values, [:option_a, :option_unset_d, :option_unset_e])
        _(constraint.exist?).must_equal true
      end

      it "should return false when all the options are missing" do
        constraint = cls.new(options, option_values, [:option_unset_d, :option_unset_e])
        _(constraint.exist?).must_equal false
      end
    end

  end

  describe HammerCLI::Options::Validators::DSL::OneOfConstraint do

    let(:cls) { HammerCLI::Options::Validators::DSL::OneOfConstraint }

    it "raises exception when nothing to check is set" do
      e = _{ cls.new(options, option_values, []) }.must_raise RuntimeError
      _(e.message).must_equal 'Set at least one expected option'
    end

    describe "#exist?" do
      it "should return true when one of the options exist" do
        constraint = cls.new(options, option_values, [:option_a, :option_unset_d, :option_unset_e])
        _(constraint.exist?).must_equal true
      end

      it "should return false when the option isn't present" do
        constraint = cls.new(options, option_values, [:option_unset_d, :option_unset_e])
        _(constraint.exist?).must_equal false
      end

      it "should return false when more than one of the options is present" do
        constraint = cls.new(options, option_values, [:option_a, :option_b])
        _(constraint.exist?).must_equal false
      end
    end

    describe "#rejected" do
      it "raises not implemented exception" do
        constraint = cls.new(options, option_values, [:option_a, :option_unset_d])
        e = _{ constraint.rejected }.must_raise NotImplementedError
        _(e.message).must_equal '#rejected is unsupported for OneOfConstraint'
      end
    end

    describe "#required" do
      it "returns nil when one of the options exist" do
        constraint = cls.new(options, option_values, [:option_a, :option_unset_d, :option_unset_e])
        assert_nil constraint.required
      end

      it "raises exception when none of the options is present" do
        constraint = cls.new(options, option_values, [:option_unset_d, :option_unset_e])
        e = _{ constraint.required }.must_raise HammerCLI::Options::Validators::ValidationError
        _(e.message).must_equal 'One of options --option-unset-d, --option-unset-e is required.'
      end

      it "raises exception when more than one of the options is present" do
        constraint = cls.new(options, option_values, [:option_a, :option_b])
        e = _{ constraint.required }.must_raise HammerCLI::Options::Validators::ValidationError
        _(e.message).must_equal 'Only one of options --option-a, --option-b can be set.'
      end
    end
  end
end
