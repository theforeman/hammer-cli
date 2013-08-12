require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::Settings do

  before :each do
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

  context "load from file" do 

    let(:config1) do
      config1 = Tempfile.new 'config'
      config1 << ":host: 'https://localhost/'\n"
      config1 << ":username: 'admin'\n"
      config1.close
      config1
    end 

    let(:config2) do
      config2 = Tempfile.new 'config2'
      config2 << ":host: 'https://localhost.localdomain/'\n"
      config2.close
      config2
    end

    it "loads settings from file" do
      settings.load_from_file [config2.path, config1.path]
      settings[:host].must_equal 'https://localhost.localdomain/'
      settings[:username].must_equal 'admin'
    end

    it "clears path history on clear invokation" do
      settings.load_from_file [config2.path]
      settings.clear
      settings.path_history.must_equal []
    end

    it "store config path history" do
      settings.load_from_file [config2.path, config1.path]
      settings.path_history.must_equal [config1.path, config2.path]
    end

  end
end

