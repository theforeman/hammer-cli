require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::Settings do

  before :each do
    # clean up global settings
    HammerCLI::Settings.clear
  end

  let(:settings) { HammerCLI::Settings }

  it "returns nil when nothing is loaded" do
    settings.get(:a).must_be_nil
    settings.get(:a, :b).must_be_nil
  end

  it "returns nil on unknown key" do
    settings.load({:a => 1})
    settings.get(:b).must_be_nil
  end

  it "returns correct value" do
    settings.load({:a => 1})
    settings.get(:a).must_equal 1
  end

  it "takes both strings and symbols" do
    settings.load({:a => 1, 'b' => 2})
    settings.get('a').must_equal 1
    settings.get(:b).must_equal 2
  end

  it "finds nested settings" do
    settings.load({:a => {:b => 1}})
    settings.get(:a, :b).must_equal 1
    settings.get(:a, 'b').must_equal 1
    settings.get('a', :b).must_equal 1
  end

  it "loads all settings" do
    settings.load({:a => 1, :b => 2})
    settings.get(:a).must_equal 1
    settings.get(:b).must_equal 2
  end

  it "dumps all settings" do
    data = {:a => 1, :b => 2}
    settings.load(data)
    settings.dump.must_equal data
  end

  it "merges settings on second load" do
    settings.load({:a => 1, :b => 2, :d => {:e => 4, :f => 5}})
    settings.load({:b => 'B', :c => 'C', :d => {:e => 'E'}})
    settings.get(:a).must_equal 1
    settings.get(:b).must_equal 'B'
    settings.get(:c).must_equal 'C'
    settings.get(:d, :e).must_equal 'E'
    settings.get(:d, :f).must_equal 5
  end

  it "clear wipes all settings" do
    settings.load({:a => 1, :b => 2})
    settings.clear
    settings.get(:a).must_be_nil
    settings.get(:b).must_be_nil
  end

  context "load from paths" do

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

    let(:config_without_creds) do
      config_without_creds = Tempfile.new('config_without_creds')
      config_without_creds << ":host: 'https://localhost.localdomain/'\n"
      config_without_creds.close
      config_without_creds
    end

    it "loads settings from file" do
      [config1.path, config2.path].each { |config| settings.load_from_file config }
      settings.get(:host).must_equal 'https://localhost.localdomain/'
      settings.get(:username).must_equal 'admin'
    end

    it "clears path history on clear invokation" do
      settings.load_from_paths [config2.path]
      settings.clear
      settings.path_history.must_equal []
    end

    it "store config path history" do
      [config1.path, config2.path].each { |config| settings.load_from_file config }
      settings.path_history.must_equal [config1.path, config2.path]
    end

    it "loads settings from dir" do
      dir = Dir.mktmpdir
      begin
        File.open(File.join(dir, "cli_config.yml"), "w") do |f|
          f.write(":param1: 'value1'\n")
        end
        module_dir = File.join(dir, 'cli.modules.d')
        Dir.mkdir(module_dir)
        File.open(File.join(module_dir, "cli_config.yml"), "w") do |f|
          f.write(":module:\n")
          f.write("  :param2: 'value2'\n")
        end

        settings.load_from_paths [dir]
        settings.load_from_file config1.path

        settings.get(:host).must_equal 'https://localhost/'
        settings.get(:username).must_equal 'admin'
        settings.get(:param1).must_equal 'value1'
        settings.get(:module, :param2).must_equal 'value2'

      ensure
        FileUtils.remove_entry dir
      end

    end
  end
end

