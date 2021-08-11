require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::CommandExtensions do
  class CustomCmd < HammerCLI::Apipie::Command
    def execute
      HammerCLI::EX_OK
    end

    def request_headers
      {}
    end

    def request_options
      {}
    end

    def request_params
      {}
    end

    public :extended_request, :extended_data
  end

  class CmdExtensions < HammerCLI::CommandExtensions
    option '--ext', 'EXT', 'ext'
    option_family(
      description: 'Test',
    ) do
      parent '--test-one', '', ''
      child '--test-two', '', ''
    end
    before_print do |data|
      data['key'] = 'value'
    end
    output do |definition|
      definition.append(Fields::Field.new)
      definition.append(Fields::Field.new)
    end
    help do |h|
      h.section('Section')
      h.text('text')
    end
    request_headers do |headers|
      headers[:ssl] = true
    end
    request_options do |options|
      options[:with_authentication] = true
    end
    request_params do |params|
      params[:thin] = true
    end
  end

  let(:cmd) { Class.new(CustomCmd) }

  context 'only' do
    it 'should extend options only' do
      cmd.extend_with(CmdExtensions.new(only: :option))
      opt = cmd.find_option('--ext')
      opt.is_a?(HammerCLI::Options::OptionDefinition).must_equal true
      cmd.output_definition.empty?.must_equal true
    end

    it 'should extend output only' do
      cmd.extend_with(CmdExtensions.new(only: :output))
      cmd.output_definition.empty?.must_equal false
      opt = cmd.find_option('--ext')
      opt.is_a?(HammerCLI::Options::OptionDefinition).must_equal false
    end

    it 'should extend help only' do
      cmd.extend_with(CmdExtensions.new(only: :help))
      cmd.new('', {}).help.must_match(/.*Section.*/)
      cmd.new('', {}).help.must_match(/.*text.*/)
    end

    it 'should extend params only' do
      cmd.extend_with(CmdExtensions.new(only: :request_params))
      cmd.new('', {}).extended_request[0].must_equal(thin: true)
      cmd.new('', {}).extended_request[1].must_equal({})
      cmd.new('', {}).extended_request[2].must_equal({})
    end

    it 'should extend headers only' do
      cmd.extend_with(CmdExtensions.new(only: :request_headers))
      cmd.new('', {}).extended_request[0].must_equal({})
      cmd.new('', {}).extended_request[1].must_equal(ssl: true)
      cmd.new('', {}).extended_request[2].must_equal({})
    end

    it 'should extend options only' do
      cmd.extend_with(CmdExtensions.new(only: :request_options))
      cmd.new('', {}).extended_request[0].must_equal({})
      cmd.new('', {}).extended_request[1].must_equal({})
      cmd.new('', {}).extended_request[2].must_equal(with_authentication: true)
    end

    it 'should extend params and options and headers' do
      cmd.extend_with(CmdExtensions.new(only: :request))
      cmd.new('', {}).extended_request[0].must_equal(thin: true)
      cmd.new('', {}).extended_request[1].must_equal(ssl: true)
      cmd.new('', {}).extended_request[2].must_equal(with_authentication: true)
    end

    it 'should extend data only' do
      cmd.extend_with(CmdExtensions.new(only: :data))
      cmd.new('', {}).help.wont_match(/.*Section.*/)
      cmd.new('', {}).help.wont_match(/.*text.*/)
      cmd.output_definition.empty?.must_equal true
      opt = cmd.find_option('--ext')
      opt.is_a?(HammerCLI::Options::OptionDefinition).must_equal false
      cmd.new('', {}).extended_request[0].must_equal({})
      cmd.new('', {}).extended_request[1].must_equal({})
      cmd.new('', {}).extended_request[2].must_equal({})
      cmd.new('', {}).extended_data({}).must_equal('key' => 'value')
    end

    it 'should extend option family only' do
      cmd.extend_with(CmdExtensions.new(only: :option_family))
      cmd.output_definition.empty?.must_equal true
      cmd.recognised_options.map(&:switches).flatten.must_equal ['-h', '--help', '--test-one', '--test-two']
    end
  end

  context 'except' do
    it 'should extend all except options' do
      cmd.extend_with(CmdExtensions.new(except: :option))
      opt = cmd.find_option('--ext')
      opt.is_a?(HammerCLI::Options::OptionDefinition).must_equal false
      cmd.output_definition.empty?.must_equal false
      cmd.new('', {}).extended_request[0].must_equal(thin: true)
      cmd.new('', {}).extended_request[1].must_equal(ssl: true)
      cmd.new('', {}).extended_request[2].must_equal(with_authentication: true)
    end

    it 'should extend all except output' do
      cmd.extend_with(CmdExtensions.new(except: :output))
      cmd.output_definition.empty?.must_equal true
      opt = cmd.find_option('--ext')
      opt.is_a?(HammerCLI::Options::OptionDefinition).must_equal true
      cmd.new('', {}).extended_request[0].must_equal(thin: true)
      cmd.new('', {}).extended_request[1].must_equal(ssl: true)
      cmd.new('', {}).extended_request[2].must_equal(with_authentication: true)
    end

    it 'should extend all except help' do
      cmd.extend_with(CmdExtensions.new(except: :help))
      cmd.new('', {}).help.wont_match(/.*Section.*/)
      cmd.new('', {}).help.wont_match(/.*text.*/)
      cmd.output_definition.empty?.must_equal false
      opt = cmd.find_option('--ext')
      opt.is_a?(HammerCLI::Options::OptionDefinition).must_equal true
      cmd.new('', {}).extended_request[0].must_equal(thin: true)
      cmd.new('', {}).extended_request[1].must_equal(ssl: true)
      cmd.new('', {}).extended_request[2].must_equal(with_authentication: true)
    end

    it 'should extend all except params' do
      cmd.extend_with(CmdExtensions.new(except: :request_params))
      cmd.new('', {}).extended_request[0].must_equal({})
      cmd.new('', {}).extended_request[1].must_equal(ssl: true)
      cmd.new('', {}).extended_request[2].must_equal(with_authentication: true)
    end

    it 'should extend all except headers' do
      cmd.extend_with(CmdExtensions.new(except: :request_headers))
      cmd.new('', {}).extended_request[0].must_equal(thin: true)
      cmd.new('', {}).extended_request[1].must_equal({})
      cmd.new('', {}).extended_request[2].must_equal(with_authentication: true)
    end

    it 'should extend all except options' do
      cmd.extend_with(CmdExtensions.new(except: :request_options))
      cmd.new('', {}).extended_request[0].must_equal(thin: true)
      cmd.new('', {}).extended_request[1].must_equal(ssl: true)
      cmd.new('', {}).extended_request[2].must_equal({})
    end

    it 'should extend all except params and options and headers' do
      cmd.extend_with(CmdExtensions.new(except: :request))
      cmd.new('', {}).extended_request[0].must_equal({})
      cmd.new('', {}).extended_request[1].must_equal({})
      cmd.new('', {}).extended_request[2].must_equal({})
    end

    it 'should extend all except data' do
      cmd.extend_with(CmdExtensions.new(except: :data))
      cmd.new('', {}).help.must_match(/.*Section.*/)
      cmd.new('', {}).help.must_match(/.*text.*/)
      cmd.output_definition.empty?.must_equal false
      opt = cmd.find_option('--ext')
      opt.is_a?(HammerCLI::Options::OptionDefinition).must_equal true
      cmd.new('', {}).extended_request[0].must_equal(thin: true)
      cmd.new('', {}).extended_request[1].must_equal(ssl: true)
      cmd.new('', {}).extended_request[2].must_equal(with_authentication: true)
      cmd.new('', {}).extended_data({}).must_equal({})
    end

    it 'should extend all except option family' do
      cmd.extend_with(CmdExtensions.new(except: :option_family))
      cmd.output_definition.empty?.must_equal false
      cmd.recognised_options.map(&:switches).flatten.must_equal ['--ext', '-h', '--help']
    end
  end

  context 'associate family' do
    it 'should associate option family' do
      cmd.extend_with(CmdExtensions.new(only: :option_family))
      cmd.option_family associate: 'test' do
        child '--test-three', '', ''
      end
      cmd.recognised_options.map(&:switches).flatten.must_equal ['-h', '--help', '--test-one', '--test-two', '--test-three']
    end
  end
end
