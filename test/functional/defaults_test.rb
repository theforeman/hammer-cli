require File.join(File.dirname(__FILE__), './test_helper')

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

  let(:defaults_path) { File.join(File.dirname(__FILE__), '../unit/fixtures/defaults/defaults.yml') }

  before do
    settings = load_yaml(defaults_path)

    @defaults = HammerCLI::Defaults.new(settings[:defaults], defaults_path)
    @defaults.stubs(:write_to_file).returns true
    @defaults.stubs(:providers).returns({ 'foreman' => TestProvider.new() })

    @context = {
      :defaults => @defaults
    }
  end

  describe 'defaults list' do
    let(:cmd) { ['defaults', 'list'] }

    it 'prints all defaults' do
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

      output = IndexMatcher.new([
        ['PARAMETER',       'VALUE'],
        ['organization_id', '3'],
        ['location_id',     'Provided by: Hammercliforeman::defaults']
      ])
      expected_result = success_result(output)

      result = run_cmd(cmd, @context)
      assert_cmd(expected_result, result)
    end

    it 'prints empty defaults' do
      @defaults.stubs(:defaults_settings).returns({})

      output = IndexLineMatcher.new(['PARAMETER', 'VALUE'])
      expected_result = success_result(output)

      result = run_cmd(cmd, @context)
      assert_cmd(expected_result, result)
    end
  end

  describe 'defaults providers' do
    let(:cmd) { ['defaults', 'providers'] }
    let(:header) { ['PROVIDER', 'SUPPORTED DEFAULTS', 'DESCRIPTION'] }

    it 'prints all providers and their supported defaults' do
      output = IndexMatcher.new([
        header,
        ['foreman',  'organization_id',    'Descr']
      ])
      expected_result = success_result(output)

      result = run_cmd(cmd, @context)
      assert_cmd(expected_result, result)
    end

    it 'prints empty providers' do
      @defaults.stubs(:providers).returns({})

      output = IndexLineMatcher.new(header)
      expected_result = success_result(output)

      result = run_cmd(cmd, @context)
      assert_cmd(expected_result, result)
    end
  end


  describe 'defaults add' do
    let(:cmd) { ['defaults', 'add'] }

    it 'adds static default' do
      options = ['--param-name=param', '--param-value=83']

      @defaults.expects(:add_defaults_to_conf).with({'param' => '83'}, nil).once

      expected_result = success_result("Added param default-option with value 83.\n")

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end

    it 'adds default from provider' do
      options = ['--param-name=organization_id', '--provider=foreman']

      @defaults.expects(:add_defaults_to_conf).with({'organization_id' => nil}, 'foreman').once

      expected_result = success_result("Added organization_id default-option with value that will be generated from the server.\n")

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end

    it 'reports unsupported option' do
      options = ['--param-name=unsupported', '--provider=foreman']
      expected_result = success_result("The param name is not supported by provider. See `hammer defaults providers` for supported params.\n")
      expected_result.expected_exit_code = HammerCLI::EX_CONFIG

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end

    it 'reports missing parameter name' do
      options = ['--param-value=83']

      expected_result = usage_error_result(cmd, "option '--param-name' is required")

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end

    it 'reports missing parameter value or source' do
      options = ['--param-name=organization_id']

      expected_result = CommandExpectation.new("You must specify value or a provider name, cant specify both.\n", "", HammerCLI::EX_USAGE)

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end

    it 'reports unknown provider' do
      options = ['--param-name=organization_id', '--provider=unknown']

      expected_result = CommandExpectation.new(
        "Provider unknown was not found. See `hammer defaults providers` for available providers.\n",
        "",
        HammerCLI::EX_USAGE
      )

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end

    it 'reports IO errors' do
      options = ['--param-name=param', '--param-value=83']

      @defaults.expects(:add_defaults_to_conf).raises(Errno::ENOENT, '/unknown/path')

      expected_result = CommandExpectation.new("No such file or directory - /unknown/path\n", "", HammerCLI::EX_CONFIG)

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end
  end

  describe 'defaults delete' do
    let(:cmd) { ['defaults', 'delete'] }

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

      expected_result = success_result("organization_id was deleted successfully.\n")

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end

    it 'reports when the variable was not found' do
      @defaults.stubs(:defaults_settings).returns({})
      @defaults.stubs(:path).returns('/path/to/defaults.yml')

      options  = ['--param-name=organization_id']

      expected_result = success_result("Couldn't find the requested param in /path/to/defaults.yml.\n")

      result = run_cmd(cmd + options, @context)
      assert_cmd(expected_result, result)
    end
  end

end
