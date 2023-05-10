require 'tempfile'

describe HammerCLI::ShellHistory do
  before :each do
    Readline::HISTORY.clear
  end

  let :history_file do
    file = Tempfile.new('history')
    file.puts "line 1"
    file.puts "line 2"
    file.close
    file
  end

  let :new_file do
    Tempfile.new('history')
  end

  describe "loading old history" do

    it "skips loading if the file does not exist" do
      HammerCLI::ShellHistory.new(new_file.path)

      _(Readline::HISTORY.to_a).must_equal []
    end

    it "preseeds readline's history" do
      HammerCLI::ShellHistory.new(history_file.path)

      _(Readline::HISTORY.to_a).must_equal ["line 1", "line 2"]
    end
  end

  describe "saving history" do
    it "creates history file if it does not exist" do
      history = HammerCLI::ShellHistory.new(new_file.path)
      history.push("some command ")

      _(File.exist?(new_file.path)).must_equal true
    end

    it "appends history to the given file" do
      history = HammerCLI::ShellHistory.new(new_file.path)
      history.push("some command ")
      history.push("another command ")

      _(new_file.read).must_equal "some command\nanother command\n"
    end

    it "appends to readline's history" do
      history = HammerCLI::ShellHistory.new(history_file.path)
      history.push("line 3")

      _(Readline::HISTORY.to_a).must_equal ["line 1", "line 2", "line 3"]
    end

    it "doesn't save exit command" do
      history = HammerCLI::ShellHistory.new(history_file.path)
      history.push("exit ")

      _(Readline::HISTORY.to_a).must_equal ["line 1", "line 2"]
    end
  end

end
