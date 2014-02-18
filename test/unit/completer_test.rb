require File.join(File.dirname(__FILE__), 'test_helper')
require 'tempfile'


describe HammerCLI::CompleterWord do


  describe "quote" do
    it "returns empty string for empty word" do
      word = HammerCLI::CompleterWord.new('')
      word.quote.must_equal ""
    end

    it "returns empty string for word without quotes" do
      word = HammerCLI::CompleterWord.new('word')
      word.quote.must_equal ""
    end

    it "recognizes double quotes" do
      word = HammerCLI::CompleterWord.new('"word')
      word.quote.must_equal '"'
    end

    it "recognizes single quotes" do
      word = HammerCLI::CompleterWord.new('\'word')
      word.quote.must_equal "'"
    end
  end

  describe "quoted?" do
    it "returns false for an unquoted word" do
      word = HammerCLI::CompleterWord.new('word')
      word.quoted?.must_equal false
    end

    it "returns true for double quotes" do
      word = HammerCLI::CompleterWord.new('"word')
      word.quoted?.must_equal true
    end

    it "returns true for single quotes" do
      word = HammerCLI::CompleterWord.new('\'word')
      word.quoted?.must_equal true
    end
  end

  describe "complete?" do
    it "considers a word without quotes complete" do
      word = HammerCLI::CompleterWord.new('word')
      word.complete?.must_equal false
    end

    it "considers a word without quotes ending with space incomplete" do
      word = HammerCLI::CompleterWord.new('word ')
      word.complete?.must_equal true
    end

    it "considers open double quotes incomplete" do
      word = HammerCLI::CompleterWord.new('"word')
      word.complete?.must_equal false
    end

    it "considers open double quotes with spaces incomplete" do
      word = HammerCLI::CompleterWord.new('"word ')
      word.complete?.must_equal false
    end

    it "considers closed double quotes complete" do
      word = HammerCLI::CompleterWord.new('"word"')
      word.complete?.must_equal true
    end

    it "considers open single quotes incomplete" do
      word = HammerCLI::CompleterWord.new('\'word')
      word.complete?.must_equal false
    end

    it "considers open single quotes with spaces incomplete" do
      word = HammerCLI::CompleterWord.new('\'word ')
      word.complete?.must_equal false
    end

    it "considers closed single quotes complete" do
      word = HammerCLI::CompleterWord.new('\'word\'')
      word.complete?.must_equal true
    end
  end

end

describe HammerCLI::CompleterLine do

  context "splitting words" do

    it "should split basic line" do
      line = HammerCLI::CompleterLine.new("architecture  list --name arch")
      line.must_equal ["architecture",  "list", "--name", "arch"]
    end

    it "should split basic line with space at the end" do
      line = HammerCLI::CompleterLine.new("architecture  list --name arch  ")
      line.must_equal ["architecture",  "list", "--name", "arch"]
    end

    it "should split on equal sign" do
      line = HammerCLI::CompleterLine.new("--name=arch")
      line.must_equal ["--name", "arch"]
    end

    it "should split when last character is equal sign" do
      line = HammerCLI::CompleterLine.new("--name=")
      line.must_equal ["--name"]
    end

    it "should split on equal sign when quotes are used" do
      line = HammerCLI::CompleterLine.new("--name='arch' ")
      line.must_equal ["--name", "arch"]
    end

    it "should split line with single quotes" do
      line = HammerCLI::CompleterLine.new("--name 'arch' ")
      line.must_equal ["--name", "arch"]
    end

    it "should split line with double quotes" do
      line = HammerCLI::CompleterLine.new("--name \"arch\"")
      line.must_equal ["--name", "arch"]
    end

    it "should split line with single quotes and space between" do
      line = HammerCLI::CompleterLine.new("--name 'ar ch '")
      line.must_equal ["--name", "ar ch "]
    end

    it "should split line with one single quote and space between" do
      line = HammerCLI::CompleterLine.new("--name 'ar ch ")
      line.must_equal ["--name", "ar ch "]
    end

    it "should split line with double quotes and space between" do
      line = HammerCLI::CompleterLine.new("--name \"ar ch \"")
      line.must_equal ["--name", "ar ch "]
    end

    it "should split line with one double quote and space between" do
      line = HammerCLI::CompleterLine.new("--name \"ar ch ")
      line.must_equal ["--name", "ar ch "]
    end

  end

  context "line complete" do

    it "should recongize incomplete line" do
      line = HammerCLI::CompleterLine.new("architecture  list --name arch")
      line.complete?.must_equal false
    end

    it "should recongize complete line" do
      line = HammerCLI::CompleterLine.new("architecture  list --name arch  ")
      line.complete?.must_equal true
    end

    it "should recongize complete line that ends with quotes" do
      line = HammerCLI::CompleterLine.new("--name 'ar ch'")
      line.complete?.must_equal true
    end

    it "should recongize complete line that ends with quotes followed by space" do
      line = HammerCLI::CompleterLine.new("--name 'ar ch' ")
      line.complete?.must_equal true
    end

    it "should recongize complete line that ends with double quotes" do
      line = HammerCLI::CompleterLine.new("--name \"ar ch\"")
      line.complete?.must_equal true
    end

    it "should recongize one quote as incomplete" do
      line = HammerCLI::CompleterLine.new("--name '")
      line.complete?.must_equal false
    end

    it "should recongize one quote followed by space as incomplete" do
      line = HammerCLI::CompleterLine.new("--name ' ")
      line.complete?.must_equal false
    end

    it "should recongize one double quote as incomplete" do
      line = HammerCLI::CompleterLine.new("--name \"")
      line.complete?.must_equal false
    end

    it "should recongize empty line as complete" do
      line = HammerCLI::CompleterLine.new("")
      line.complete?.must_equal true
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
        ["small ", "tall ", "smel ly"]
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

    let(:ape_completions) { ["makkak ", "malpa ", "orangutan ", "--hairy ", "--weight ", "--height ", "-h ", "--help "] }

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
      completer.complete("ape ").sort.must_equal ape_completions.sort
    end

    it "should offer all available subcommands and options even if a flag has been passed" do
      completer.complete("ape --hairy ").sort.must_equal ape_completions.sort
    end

    it "should offer all available subcommands and options even if an option has been passed" do
      completer.complete("ape --weight 12kg ").sort.must_equal ape_completions.sort
    end

    it "should offer all available subcommands and options even if an egual sign option has been passed" do
      completer.complete("ape --weight=12kg ").sort.must_equal ape_completions.sort
    end

    it "should offer all available subcommands and options when quoted value was passed" do
      completer.complete("ape --weight '12 kg' ").sort.must_equal ape_completions.sort
    end

    it "should offer all available subcommands and options when double quoted value was passed" do
      completer.complete("ape --weight \"12 kg\" ").sort.must_equal ape_completions.sort
    end

    it "should offer all available subcommands and options when quoted value with equal sign was passed" do
      completer.complete("ape --weight='12 kg' ").sort.must_equal ape_completions.sort
    end
  end


  context "option value completion" do
    it "should complete option values" do
      completer.complete("ape --height ").sort.must_equal ["small ", "tall ", "smel ly"].sort
    end

    it "should complete option values when equal sign is used" do
      completer.complete("ape --height=").sort.must_equal ["small ", "tall ", "smel ly"].sort
    end

    it "should complete option values" do
      completer.complete("ape --height s").must_equal ["small ", "smel ly"]
    end

    it "should complete quoted option values" do
      completer.complete("ape --height 's").must_equal ["'small' ", "'smel ly"]
    end

    it "should complete quoted option values" do
      completer.complete("ape --height 'smel l").must_equal ["'smel ly"]
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

