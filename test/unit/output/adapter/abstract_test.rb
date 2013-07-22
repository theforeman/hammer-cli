require_relative '../../test_helper'

describe HammerCLI::Output::Adapter::Abstract do

  let(:adapter) { HammerCLI::Output::Adapter::Abstract.new }

  it "should print message to stdout" do
    proc { adapter.print_message("MESSAGE") }.must_output(/.*MESSAGE.*/, "")
  end

  it "should raise not implemented on print_records" do
    proc { adapter.print_records([], []) }.must_raise NotImplementedError
  end

  context "error messages" do
    it "should print error message to stderr" do
      proc { adapter.print_error("MESSAGE") }.must_output("", /.*MESSAGE.*/)
    end

    let(:expected_output) { "MESSAGE:\n"+
                            "  error\n"+
                            "  message\n"+
                            "  details\n"
    }

    it "should print list details of error to stderr" do
      proc { adapter.print_error("MESSAGE", ["error", "message", "details"]) }.must_output("", expected_output)
    end

    it "should print string details of error to stderr" do
      proc { adapter.print_error("MESSAGE", "error\nmessage\ndetails") }.must_output("", expected_output)
    end

  end

end
