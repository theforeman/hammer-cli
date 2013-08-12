require File.join(File.dirname(__FILE__), 'test_helper')


# describe HammerCLI::OptionValidator do


# end

describe "constraints" do

  class FakeCmd < Clamp::Command
    def initialize
      super("")
      @option_a = 1
      @option_b = 1
      @option_c = 1
      @option_d = nil
      @option_e = nil
    end
  end

  let(:cmd) {
    FakeCmd.new
  }

  let(:option_names) { ["a", "b", "c", "d", "e"] }
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
      it "should return true when all the options exist" do
        constraint = cls.new(options, [:option_a, :option_b, :option_c])
        constraint.exist?.must_equal true
      end

      it "should return false when one of the options is missing" do
        constraint = cls.new(options, [:option_a, :option_b, :option_c, :option_d])
        constraint.exist?.must_equal false
      end
    end

  end

  describe HammerCLI::Validator::AnyConstraint do

    let(:cls) { HammerCLI::Validator::AnyConstraint }

    describe "exist?" do
      it "should return true when one of the options exist" do
        constraint = cls.new(options, [:option_a, :option_d, :option_e])
        constraint.exist?.must_equal true
      end

      it "should return false when all the options are missing" do
        constraint = cls.new(options, [:option_d, :option_e])
        constraint.exist?.must_equal false
      end
    end

  end


end
