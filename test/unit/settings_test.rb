require_relative 'test_helper'

describe HammerCLI::Settings do

  after :each do
    # clean up global settings
    HammerCLI::Settings.clear
  end
  
  let(:settings) { HammerCLI::Settings }

  it "returns nil when nothing is loaded" do
    settings[:a].must_be_nil
  end

  it "returns nil on unknown key" do
    settings.load({:a => 1})
    settings[:b].must_be_nil
  end

  it "returns correct value" do
    settings.load({:a => 1})
    settings[:a].must_equal 1
  end

  it "takes both strings and symbols" do
    settings.load({:a => 1, 'b' => 2})
    settings['a'].must_equal 1
    settings[:b].must_equal 2
  end

  it "loads all settings" do
    settings.load({:a => 1, :b => 2})
    settings[:a].must_equal 1
    settings[:b].must_equal 2
  end

  it "merges settings on second load" do
    settings.load({:a => 1, :b => 2})
    settings.load({:b => 'B', :c => 'C'})
    settings[:a].must_equal 1
    settings[:b].must_equal 'B'
    settings[:c].must_equal 'C'
  end

  it "clear wipes all settings" do
    settings.load({:a => 1, :b => 2})
    settings.clear
    settings[:a].must_be_nil
    settings[:b].must_be_nil
  end


  it "loads settings from file" do
    settings1 = Tempfile.new 'settings'
    settings1 << ":host: 'https://localhost/'\n"
    settings1 << ":username: 'admin'\n"
    settings1.close
    settings2 = Tempfile.new 'settings2'
    settings2 << ":host: 'https://localhost.localdomain/'\n"
    settings2.close
    settings.load_from_file [settings2.to_path, settings1.to_path]
    settings[:host].must_equal 'https://localhost.localdomain/'
    settings[:username].must_equal 'admin'
  end

end

