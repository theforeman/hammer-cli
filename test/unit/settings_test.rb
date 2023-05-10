require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::Settings do

  before :each do
    # clean up global settings
    HammerCLI::Settings.clear
  end

  let(:settings) { HammerCLI::Settings }

  it "returns nil when nothing is loaded" do
    _(settings.get(:a)).must_be_nil
    _(settings.get(:a, :b)).must_be_nil
  end

  it "returns nil on unknown key" do
    settings.load({:a => 1})
    _(settings.get(:b)).must_be_nil
  end

  it "returns correct value" do
    settings.load({:a => 1})
    _(settings.get(:a)).must_equal 1
  end

  it "takes both strings and symbols" do
    settings.load({:a => 1, 'b' => 2})
    _(settings.get('a')).must_equal 1
    _(settings.get(:b)).must_equal 2
  end

  it "finds nested settings" do
    settings.load({:a => {:b => 1}})
    _(settings.get(:a, :b)).must_equal 1
    _(settings.get(:a, 'b')).must_equal 1
    _(settings.get('a', :b)).must_equal 1
  end

  it "loads all settings" do
    settings.load({:a => 1, :b => 2})
    _(settings.get(:a)).must_equal 1
    _(settings.get(:b)).must_equal 2
  end

  it "dumps all settings" do
    settings.empty
    data = {:a => 1, :b => 2}
    settings.load(data)
    _(settings.dump).must_equal data
  end

  it "merges hash settings on second load" do
    settings.load({:a => 1, :b => 2, :d => {:e => 4, :f => 5}})
    settings.load({:b => 'B', :c => 'C', :d => {:e => 'E'}})
    _(settings.get(:a)).must_equal 1
    _(settings.get(:b)).must_equal 'B'
    _(settings.get(:c)).must_equal 'C'
    _(settings.get(:d, :e)).must_equal 'E'
    _(settings.get(:d, :f)).must_equal 5
  end

  it "merges array settings on second load" do
    settings.load({:x => [:a, :b]})
    settings.load({:x => [:c, :d]})
    _(settings.get(:x)[0]).must_equal :a
    _(settings.get(:x)[1]).must_equal :b
    _(settings.get(:x)[2]).must_equal :c
    _(settings.get(:x)[3]).must_equal :d
    _(settings.get(:x).size).must_equal 4
  end

  it "clear wipes all settings but default values" do
    settings.load({:a => 1, :b => 2})
    settings.clear
    _(settings.get(:a)).must_be_nil
    _(settings.get(:b)).must_be_nil
    settings.default_settings.each { |key, val| _(settings.get(key)).must_equal val }
  end

  it "empty wipes all settings including default values" do
    settings.load({:a => 1, :b => 2})
    settings.empty
    _(settings.dump).must_equal({})
  end

  it "initializes settings with default settings" do
    settings.instance_variable_set(:@settings_hash, nil)
    _(settings.dump).must_equal settings.default_settings
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
      _(settings.get(:host)).must_equal 'https://localhost.localdomain/'
      _(settings.get(:username)).must_equal 'admin'
    end

    it "clears path history on clear invokation" do
      settings.load_from_paths [config2.path]
      settings.clear
      _(settings.path_history).must_equal []
    end

    it "store config path history" do
      [config1.path, config2.path].each { |config| settings.load_from_file config }
      _(settings.path_history).must_equal [config1.path, config2.path]
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

        _(settings.get(:host)).must_equal 'https://localhost/'
        _(settings.get(:username)).must_equal 'admin'
        _(settings.get(:param1)).must_equal 'value1'
        _(settings.get(:module, :param2)).must_equal 'value2'

      ensure
        FileUtils.remove_entry dir
      end

    end
  end
end

