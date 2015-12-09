require File.join(File.dirname(__FILE__), '../unit/test_helper')
describe 'commands' do

  class TestProvider < HammerCLI::BaseDefaultsProvider

    def initialize
      @provider_name = 'foreman'
      @supported_defaults = ['organization_id']
      @description = 'Descr'
    end

    def self.get_defaults(param)
      32
    end
  end

  before do
    settings  = YAML::load(File.open(FILEPATH))
    @defaults = HammerCLI::Defaults.new(settings[:defaults], FILEPATH)
    @defaults.stubs(:write_to_file).returns true
    @defaults.stubs(:providers).returns({ 'foreman' => TestProvider.new() })

    @context = {
      :defaults => @defaults
    }
  end

  def run_cmd(cmd_class, options)
    capture_io do
      cmd_class.run('hammer', options, @context)
    end
  end

  describe 'defaults list' do

    it 'it prints all defaults' do
      header = 'Parameter,Value'
      default_values = {
        :organization_id => {
          :value => 3,
        },
        :location_id     => {
          :provider => 'HammerCLIForeman::Defaults'
        }
      }
      @defaults.stubs(:defaults_settings).returns(default_values)

      out, err = run_cmd(HammerCLI::DefaultsCommand::ListDefaultsCommand, [])
      assert_equal "", err
      assert_match /PARAMETER[ |]*VALUE/, out
      assert_match /organization_id[ |]*3/, out
      assert_match /location_id[ |]*Provided by: Hammercliforeman::defaults/, out
    end

    it 'prints empty defaults' do
      @defaults.stubs(:defaults_settings).returns({})

      out, err = run_cmd(HammerCLI::DefaultsCommand::ListDefaultsCommand, [])
      assert_equal "", err
      assert_match /PARAMETER[ |]*VALUE/, out
    end
  end

  describe 'defaults providers' do
    header = /PROVIDER[ |]*SUPPORTED DEFAULTS[ |]*DESCRIPTION/

    it 'prints all providers and their supported defaults' do
      out, err = run_cmd(HammerCLI::DefaultsCommand::ProvidersDefaultsCommand, [])
      assert_equal "", err
      assert_match header, out
      assert_match /foreman[ |]*organization_id[ |]*Descr/, out
    end

    it 'prints empty providers' do
      @defaults.stubs(:providers).returns({})
      out, err = run_cmd(HammerCLI::DefaultsCommand::ProvidersDefaultsCommand, [])
      assert_equal "", err
      assert_match header, out
    end
  end


  describe 'defaults add' do
    it 'adds static default' do
      options = ['--param-name=param', '--param-value=83']

      @defaults.expects(:add_defaults_to_conf).with({'param' => '83'}, nil).once

      out, err = run_cmd(HammerCLI::DefaultsCommand::AddDefaultsCommand, options)
      assert_equal "", err
      assert_equal "Added param default-option with value 83.\n", out
    end

    it 'adds default from provider' do
      options = ['--param-name=organization_id', '--provider=foreman']

      @defaults.expects(:add_defaults_to_conf).with({'organization_id' => nil}, 'foreman').once

      out, err = run_cmd(HammerCLI::DefaultsCommand::AddDefaultsCommand, options)
      assert_equal "", err
      assert_equal "Added organization_id default-option with value that will be generated from the server.\n", out
    end

    it 'reports unsupported option' do
      options = ['--param-name=unsupported', '--provider=foreman']
      out, err = run_cmd(HammerCLI::DefaultsCommand::AddDefaultsCommand, options)
      assert_equal "", err
      assert_equal "The param name is not supported by provider. See `hammer defaults providers` for supported params.\n", out
    end

    it 'reports missing parameter name' do
      options = ['--param-value=83']

      out, err = capture_io do
        HammerCLI::DefaultsCommand::AddDefaultsCommand.run('hammer', options, @context)
      end
      assert_match "option '--param-name' is required", err
      assert_equal "", out
    end

    it 'reports missing parameter value or source' do
      options = ['--param-name=organization_id']

      out, err = run_cmd(HammerCLI::DefaultsCommand::AddDefaultsCommand, options)
      assert_equal "", err
      assert_match "You must specify value or a provider name, cant specify both.", out
    end

    it 'reports unknown provider' do
      options = ['--param-name=organization_id', '--provider=unknown']

      out, err = run_cmd(HammerCLI::DefaultsCommand::AddDefaultsCommand, options)
      assert_equal "", err
      assert_equal "Provider unknown was not found. See `hammer defaults providers` for available providers.\n", out
    end

    it 'reports IO errors' do
      options = ['--param-name=param', '--param-value=83']

      @defaults.expects(:add_defaults_to_conf).raises(Errno::ENOENT, '/unknown/path')

      out, err = run_cmd(HammerCLI::DefaultsCommand::AddDefaultsCommand, options)
      assert_equal "", err
      assert_equal "No such file or directory - /unknown/path\n", out
    end
  end

  describe 'defaults delete' do
    it 'removes the defaults' do
      default_values = {
        :organization_id => {
          :value       => 3,
          :from_server => false
        }
      }
      @defaults.stubs(:defaults_settings).returns(default_values)
      @defaults.expects(:delete_default_from_conf).once

      options = ['--param-name=organization_id']

      out, err = run_cmd(HammerCLI::DefaultsCommand::DeleteDefaultsCommand, options)
      assert_equal "", err
      assert_equal "organization_id was deleted successfully.\n", out
    end

    it 'reports when the variable was not found' do
      @defaults.stubs(:defaults_settings).returns({})
      @defaults.stubs(:path).returns('/path/to/defaults.yml')

      options  = ['--param-name=organization_id']
      out, err = run_cmd(HammerCLI::DefaultsCommand::DeleteDefaultsCommand, options)
      assert_equal "", err
      assert_equal "Couldn't find the requested param in /path/to/defaults.yml.\n", out
    end
  end

end
