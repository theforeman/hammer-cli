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
        proc{ constraint.exist? }.must_raise NotImplementedError
      end
    end

    describe "rejected" do
      it "should raise exception when exist? returns true" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(true)
        proc{ constraint.rejected }.must_raise HammerCLI::Options::Validators::ValidationError
      end

      it "should raise exception with a message" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(true)
        begin
          constraint.rejected :msg => "CUSTOM MESSAGE"
        rescue HammerCLI::Options::Validators::ValidationError => e
          e.message.must_equal "CUSTOM MESSAGE"
        end
      end

      it "should return nil when exist? returns true" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(false)
        constraint.rejected.must_equal nil
      end
    end

    describe "required" do
      it "should raise exception when exist? returns true" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(false)
        proc{ constraint.required }.must_raise HammerCLI::Options::Validators::ValidationError
      end

      it "should raise exception with a message" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(false)
        begin
          constraint.rejected :msg => "CUSTOM MESSAGE"
        rescue HammerCLI::Options::Validators::ValidationError => e
          e.message.must_equal "CUSTOM MESSAGE"
        end
      end

      it "should return nil when exist? returns true" do
        constraint = cls.new(options, option_values, [])
        constraint.stubs(:exist?).returns(true)
        constraint.required.must_equal nil
      end
    end

  end

  describe HammerCLI::Options::Validators::DSL::AllConstraint do

    let(:cls) { HammerCLI::Options::Validators::DSL::AllConstraint }

    describe "exist?" do

      it "should return true when no options are passed" do
        constraint = cls.new(options, option_values, [])
        constraint.exist?.must_equal true
      end

      it "should return true when all the options exist" do
        constraint = cls.new(options, option_values, [:option_a, :option_b, :option_c])
        constraint.exist?.must_equal true
      end

      it "should return false when one of the options is missing" do
        constraint = cls.new(options, option_values, [:option_a, :option_b, :option_c, :option_unset_d])
        constraint.exist?.must_equal false
      end
    end

  end

  describe HammerCLI::Options::Validators::DSL::OneOptionConstraint do
    let(:cls) { HammerCLI::Options::Validators::DSL::OneOptionConstraint }

    describe "exist?" do
      it "should return true when the option exist" do
        constraint = cls.new(options, option_values, :option_a)
        constraint.exist?.must_equal true
      end

      it "should return false when the option is missing" do
        constraint = cls.new(options, option_values, :option_unset_d)
        constraint.exist?.must_equal false
      end
    end

    describe "#rejected" do
      it "returns nil when the option is missing" do
        constraint = cls.new(options, option_values, :option_unset_d)
        constraint.rejected.must_equal nil
      end

      it "raises exception when the option is present" do
        constraint = cls.new(options, option_values, :option_a)
        e = proc{ constraint.rejected }.must_raise HammerCLI::Options::Validators::ValidationError
        e.message.must_equal "You can't set option --option-a."
      end
    end

    describe "#required" do
      it "returns nil when the option exist" do
        constraint = cls.new(options, option_values, :option_a)
        constraint.required.must_equal nil
      end

      it "raises exception when the option is present" do
        constraint = cls.new(options, option_values, :option_unset_d)
        e = proc{ constraint.required }.must_raise HammerCLI::Options::Validators::ValidationError
        e.message.must_equal 'Option --option-unset-d is required.'
      end
    end

    describe "#value" do
      it "returns value of the option" do
        constraint = cls.new(options, option_values, :option_a)
        constraint.value.must_equal 1
      end

      it "returns nil when the option is missing" do
        constraint = cls.new(options, option_values, :option_unset_d)
        constraint.value.must_equal nil
      end
    end
  end

  describe HammerCLI::Options::Validators::DSL::AnyConstraint do

    let(:cls) { HammerCLI::Options::Validators::DSL::AnyConstraint }

    describe "exist?" do

      it "should return true when no options are passed" do
        constraint = cls.new(options, option_values, [])
        constraint.exist?.must_equal true
      end

      it "should return true when one of the options exist" do
        constraint = cls.new(options, option_values, [:option_a, :option_unset_d, :option_unset_e])
        constraint.exist?.must_equal true
      end

      it "should return false when all the options are missing" do
        constraint = cls.new(options, option_values, [:option_unset_d, :option_unset_e])
        constraint.exist?.must_equal false
      end
    end

  end

  describe HammerCLI::Options::Validators::DSL::OneOfConstraint do

    let(:cls) { HammerCLI::Options::Validators::DSL::OneOfConstraint }

    it "raises exception when nothing to check is set" do
      e = proc{ cls.new(options, option_values, []) }.must_raise RuntimeError
      e.message.must_equal 'Set at least one expected option'
    end

    describe "#exist?" do
      it "should return true when one of the options exist" do
        constraint = cls.new(options, option_values, [:option_a, :option_unset_d, :option_unset_e])
        constraint.exist?.must_equal true
      end

      it "should return false when the option isn't present" do
        constraint = cls.new(options, option_values, [:option_unset_d, :option_unset_e])
        constraint.exist?.must_equal false
      end

      it "should return false when more than one of the options is present" do
        constraint = cls.new(options, option_values, [:option_a, :option_b])
        constraint.exist?.must_equal false
      end
    end

    describe "#rejected" do
      it "raises not implemented exception" do
        constraint = cls.new(options, option_values, [:option_a, :option_unset_d])
        e = proc{ constraint.rejected }.must_raise NotImplementedError
        e.message.must_equal '#rejected is unsupported for OneOfConstraint'
      end
    end

    describe "#required" do
      it "returns nil when one of the options exist" do
        constraint = cls.new(options, option_values, [:option_a, :option_unset_d, :option_unset_e])
        constraint.required.must_equal nil
      end

      it "raises exception when none of the options is present" do
        constraint = cls.new(options, option_values, [:option_unset_d, :option_unset_e])
        e = proc{ constraint.required }.must_raise HammerCLI::Options::Validators::ValidationError
        e.message.must_equal 'One of options --option-unset-d, --option-unset-e is required.'
      end

      it "raises exception when more than one of the options is present" do
        constraint = cls.new(options, option_values, [:option_a, :option_b])
        e = proc{ constraint.required }.must_raise HammerCLI::Options::Validators::ValidationError
        e.message.must_equal 'Only one of options --option-a, --option-b can be set.'
      end
    end
  end
end
