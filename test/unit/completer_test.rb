require File.join(File.dirname(__FILE__), 'test_helper')
require 'tempfile'


describe HammerCLI::CompleterLine do

  let(:unfinished_line) { "architecture list --name arch" }
  let(:finished_line) { "architecture list --name arch " }

  context "splitting words" do

    it "should split basic line" do
      line = HammerCLI::CompleterLine.new(finished_line)
      line.must_equal ["architecture",  "list", "--name", "arch"]
    end

    it "should split basic line with space at the end" do
      line = HammerCLI::CompleterLine.new(finished_line)
      line.must_equal ["architecture",  "list", "--name", "arch"]
    end

  end

  context "last word finished" do

    it "should recongize unfinished line" do
      line = HammerCLI::CompleterLine.new(unfinished_line)
      line.finished?.must_equal false
    end

    it "should recongize finished line" do
      line = HammerCLI::CompleterLine.new(finished_line)
      line.finished?.must_equal true
    end

    it "should recongize empty line as finished" do
      line = HammerCLI::CompleterLine.new("")
      line.finished?.must_equal true
    end

  end

end


describe HammerCLI::Completer do


  class FakeMainCmd < HammerCLI::AbstractCommand

    class FakeNormalizer < HammerCLI::Options::Normalizers::AbstractNormalizer

      def format(val)
        val
      end

      def complete(val)
        ["small ", "tall "]
      end

    end

    class AnabolicCmd < HammerCLI::AbstractCommand
      command_name "anabolic"
    end

    class ApeCmd < HammerCLI::AbstractCommand
      command_name "ape"

      option "--hairy", :flag, "Description"
      option "--weight", "WEIGHT", "Description",
        :format => FakeNormalizer.new
      option "--height", "HEIGHT", "Description",
        :format => FakeNormalizer.new

      class MakkakCmd < HammerCLI::AbstractCommand
        command_name "makkak"
      end

      class MalpaCmd < HammerCLI::AbstractCommand
        command_name "malpa"
      end

      class OrangutanCmd < HammerCLI::AbstractCommand
        command_name "orangutan"
      end

      autoload_subcommands
    end

    class ApocalypseCmd < HammerCLI::AbstractCommand
      command_name "apocalypse"
    end

    class BeastCmd < HammerCLI::AbstractCommand
      command_name "beast"
    end

    autoload_subcommands
  end


  let(:completer) { HammerCLI::Completer.new(FakeMainCmd) }

  context "command completion" do
    it "should offer all available commands" do
      completer.complete("").sort.must_equal ["anabolic ", "ape ", "apocalypse ", "beast ", "-h ", "--help "].sort
    end

    it "should offer nothing when the line does not match" do
      completer.complete("x").must_equal []
    end

    it "should filter by first letter" do
      completer.complete("a").sort.must_equal ["anabolic ", "ape ", "apocalypse "].sort
    end

    it "should filter by first two letters" do
      completer.complete("ap").sort.must_equal ["ape ", "apocalypse "].sort
    end

    it "should offer all available subcommands and options" do
      completer.complete("ape ").sort.must_equal ["makkak ", "malpa ", "orangutan ", "--hairy ", "--weight ", "--height ", "-h ", "--help "].sort
    end

    it "should offer all available subcommands and options even if a flag has been passed" do
      completer.complete("ape --hairy ").sort.must_equal ["makkak ", "malpa ", "orangutan ", "--hairy ", "--weight ", "--height ", "-h ", "--help "].sort
    end

    it "should offer all available subcommands and options even if an option has been passed" do
      completer.complete("ape --weight 12kg ").sort.must_equal ["makkak ", "malpa ", "orangutan ", "--hairy ", "--weight ", "--height ", "-h ", "--help "].sort
    end

    it "should offer all available subcommands and options even if an egual sign option has been passed" do
      completer.complete("ape --weight=12kg ").sort.must_equal ["makkak ", "malpa ", "orangutan ", "--hairy ", "--weight ", "--height ", "-h ", "--help "].sort
    end
  end


  context "option value completion" do
    it "should complete option values" do
      completer.complete("ape --height ").sort.must_equal ["small ", "tall "].sort
    end

    it "should complete option values" do
      completer.complete("ape --height s").must_equal ["small "]
    end
  end


  context "subcommand completion" do
    it "should filter subcommands by first letter" do
      completer.complete("ape m").sort.must_equal ["makkak ", "malpa "].sort
    end

    it "should offer nothing when the line does not match any subcommand" do
      completer.complete("ape x").must_equal []
    end

    it "should ignore flags specified before the last command" do
      completer.complete("ape --hairy m").sort.must_equal ["makkak ", "malpa "].sort
    end

    it "should ignore options specified before the last command" do
      completer.complete("ape --weight 12kg m").sort.must_equal ["makkak ", "malpa "].sort
    end

    it "should ignore equal sign separated options specified before the last command" do
      completer.complete("ape --weight=12kg m").sort.must_equal ["makkak ", "malpa "].sort
    end

    it "should filter subcommands by first three letters" do
      completer.complete("ape mak").must_equal ["makkak "]
    end
  end

end

