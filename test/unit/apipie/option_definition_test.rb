require File.join(File.dirname(__FILE__), '../test_helper')

# require 'hammer_cli/options/option_definition'

describe HammerCLI::Apipie::OptionDefinition do

  let(:opt) { HammerCLI::Apipie::OptionDefinition.new("--opt", "OPT", "", :referenced_resource => @referenced_resource) }

  describe "referenced resource" do
    it "should be nil by default" do
      opt.referenced_resource.must_equal nil
    end

    it "should set referenced resource" do
      @referenced_resource = "organization"
      opt.referenced_resource.must_equal "organization"
    end

    it "should convert referenced resource name to string" do
      @referenced_resource = :organization
      opt.referenced_resource.must_equal "organization"
    end

  end

  let(:opt2) { HammerCLI::Apipie::OptionDefinition.new("--opt2", "OPT2", "&#39;OPT2&#39;", :referenced_resource => @referenced_resource) }

  describe "Option Description should be converted" do
    it "should be converted" do
      opt2.description.must_equal "'OPT2'"
    end

  end
end

