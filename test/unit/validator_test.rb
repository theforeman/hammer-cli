require File.join(File.dirname(__FILE__), 'test_helper')

describe "constraints" do

  class FakeCmd < Clamp::Command
    def initialize
      context = {
        :defaults => HammerCLI::Defaults.new({ :default => { :value => 2 }})
      }
      super("", context)
      @option_a = 1
      @option_b = 1
      @option_c = 1
      @option_unset_d = nil
      @option_unset_e = nil
    end
  end

  let(:cmd) {
    FakeCmd.new
  }

  let(:option_names) { ["a", "b", "c", "unset-d", "unset-e", "default"] }
  let(:options_def) {
    option_names.collect{ |n| Clamp::Option::Definition.new(["-"+n, "--option-"+n], n.upcase, "Option "+n.upcase) }
  }
  let(:options) { options_def.collect{|d| d.of(cmd) } }

  describe HammerCLI::Validator::BaseConstraint do

    let(:cls) { HammerCLI::Validator::BaseConstraint }

    describe "exist?" do
      it "throws not implemented error" do
        constraint = cls.new(options, [:option_a, :option_b, :option_c])
        proc{ constraint.exist? }.must_raise NotImplementedError
      end
    end

    describe "rejected" do
      it "should raise exception when exist? returns true" do
        constraint = cls.new(options, [])
        constraint.stubs(:exist?).returns(true)
        proc{ constraint.rejected }.must_raise HammerCLI::Validator::ValidationError
      end

      it "should raise exception with a message" do
        constraint = cls.new(options, [])
        constraint.stubs(:exist?).returns(true)
        begin
          constraint.rejected :msg => "CUSTOM MESSAGE"
        rescue HammerCLI::Validator::ValidationError => e
          e.message.must_equal "CUSTOM MESSAGE"
        end
      end

      it "should return nil when exist? returns true" do
        constraint = cls.new(options, [])
        constraint.stubs(:exist?).returns(false)
        constraint.rejected.must_equal nil
      end
    end

    describe "required" do
      it "should raise exception when exist? returns true" do
        constraint = cls.new(options, [])
        constraint.stubs(:exist?).returns(false)
        proc{ constraint.required }.must_raise HammerCLI::Validator::ValidationError
      end

      it "should raise exception with a message" do
        constraint = cls.new(options, [])
        constraint.stubs(:exist?).returns(false)
        begin
          constraint.rejected :msg => "CUSTOM MESSAGE"
        rescue HammerCLI::Validator::ValidationError => e
          e.message.must_equal "CUSTOM MESSAGE"
        end
      end

      it "should return nil when exist? returns true" do
        constraint = cls.new(options, [])
        constraint.stubs(:exist?).returns(true)
        constraint.required.must_equal nil
      end
    end

  end

  describe HammerCLI::Validator::AllConstraint do

    let(:cls) { HammerCLI::Validator::AllConstraint }

    describe "exist?" do

      it "should return true when no options are passed" do
        constraint = cls.new(options, [])
        constraint.exist?.must_equal true
      end

      it "should return true when all the options exist" do
        constraint = cls.new(options, [:option_a, :option_b, :option_c])
        constraint.exist?.must_equal true
      end

      it "should return true when all the options exist or are set in the defaults" do
        constraint = cls.new(options, [:option_a, :option_b, :option_c, :option_default])
        constraint.exist?.must_equal true
      end

      it "should return false when one of the options is missing" do
        constraint = cls.new(options, [:option_a, :option_b, :option_c, :option_unset_d])
        constraint.exist?.must_equal false
      end
    end

  end

  describe HammerCLI::Validator::OneOptionConstraint do
    let(:cls) { HammerCLI::Validator::OneOptionConstraint }

    describe "exist?" do
      it "should return true when the option exist" do
        constraint = cls.new(options, :option_a)
        constraint.exist?.must_equal true
      end

      it "should return true when the option is set in the defaults" do
        constraint = cls.new(options, :option_default)
        constraint.exist?.must_equal true
      end

      it "should return false when the option is missing" do
        constraint = cls.new(options, :option_unset_d)
        constraint.exist?.must_equal false
      end
    end

    describe "#rejected" do
      it "returns nil when the option is missing" do
        constraint = cls.new(options, :option_unset_d)
        constraint.rejected.must_equal nil
      end

      it "raises exception when the option is present" do
        constraint = cls.new(options, :option_a)
        e = proc{ constraint.rejected }.must_raise HammerCLI::Validator::ValidationError
        e.message.must_equal "You can't set option --option-a."
      end
    end

    describe "#required" do
      it "returns nil when the option exist" do
        constraint = cls.new(options, :option_a)
        constraint.required.must_equal nil
      end

      it "raises exception when the option is present" do
        constraint = cls.new(options, :option_unset_d)
        e = proc{ constraint.required }.must_raise HammerCLI::Validator::ValidationError
        e.message.must_equal 'Option --option-unset-d is required.'
      end
    end

    describe "#value" do
      it "returns value of the option" do
        constraint = cls.new(options, :option_a)
        constraint.value.must_equal 1
      end

      it "returns value of the option defined in the defaults" do
        constraint = cls.new(options, :option_default)
        constraint.value.must_equal 2
      end

      it "returns nil when the option is missing" do
        constraint = cls.new(options, :option_unset_d)
        constraint.value.must_equal nil
      end
    end
  end

  describe HammerCLI::Validator::AnyConstraint do

    let(:cls) { HammerCLI::Validator::AnyConstraint }

    describe "exist?" do

      it "should return true when no options are passed" do
        constraint = cls.new(options, [])
        constraint.exist?.must_equal true
      end

      it "should return true when one of the options exist" do
        constraint = cls.new(options, [:option_a, :option_unset_d, :option_unset_e])
        constraint.exist?.must_equal true
      end

      it "should return true when one of the options exist and is set in the defaults" do
        constraint = cls.new(options, [:option_default, :option_unset_d, :option_unset_e])
        constraint.exist?.must_equal true
      end

      it "should return false when all the options are missing" do
        constraint = cls.new(options, [:option_unset_d, :option_unset_e])
        constraint.exist?.must_equal false
      end
    end

  end

  describe HammerCLI::Validator::OneOfConstraint do

    let(:cls) { HammerCLI::Validator::OneOfConstraint }

    it "raises exception when nothing to check is set" do
      e = proc{ cls.new(options, []) }.must_raise RuntimeError
      e.message.must_equal 'Set at least one expected option'
    end

    describe "#exist?" do
      it "should return true when one of the options exist" do
        constraint = cls.new(options, [:option_a, :option_unset_d, :option_unset_e])
        constraint.exist?.must_equal true
      end

      it "should return true when one of the options exist and is set in the defaults" do
        constraint = cls.new(options, [:option_default, :option_unset_d, :option_unset_e])
        constraint.exist?.must_equal true
      end

      it "should return false when the option isn't present" do
        constraint = cls.new(options, [:option_unset_d, :option_unset_e])
        constraint.exist?.must_equal false
      end

      it "should return false when more than one of the options is present" do
        constraint = cls.new(options, [:option_a, :option_b])
        constraint.exist?.must_equal false
      end
    end

    describe "#rejected" do
      it "raises not implemented exception" do
        constraint = cls.new(options, [:option_a, :option_unset_d])
        e = proc{ constraint.rejected }.must_raise NotImplementedError
        e.message.must_equal '#rejected is unsupported for OneOfConstraint'
      end
    end

    describe "#required" do
      it "returns nil when one of the options exist" do
        constraint = cls.new(options, [:option_a, :option_unset_d, :option_unset_e])
        constraint.required.must_equal nil
      end

      it "raises exception when none of the options is present" do
        constraint = cls.new(options, [:option_unset_d, :option_unset_e])
        e = proc{ constraint.required }.must_raise HammerCLI::Validator::ValidationError
        e.message.must_equal 'One of options --option-unset-d, --option-unset-e is required.'
      end

      it "raises exception when more than one of the options is present" do
        constraint = cls.new(options, [:option_a, :option_b])
        e = proc{ constraint.required }.must_raise HammerCLI::Validator::ValidationError
        e.message.must_equal 'Only one of options --option-a, --option-b can be set.'
      end
    end
  end
end
