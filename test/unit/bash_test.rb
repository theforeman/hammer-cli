require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::Bash::Completion do
  describe '#complete' do
    let(:dict) do
      {
        'host' => {
          'create' => {
            '--installed-products-attributes' => { type: :schema, schema: '"product_id=string\,product_name=string\,arch=string\,version=string, ... "' },
            '--help' => { type: :flag },
            '--build' => { type: :flag },
            '--managed' => { type: :enum, values: %w[yes no] },
            '--volume' => { type: :multienum, values: %w[first second third] },
            '--config-group-ids' => { type: :list },
            '--params' => { type: :key_value_list },
            '--log' => { type: :file, filter: '.*\.log$' },
            '--pool' => { type: :directory },
            '-t' => { type: :value },
            :params => [{ type: :directory }, { type: :value }, { type: :file }]
          },
          '--dry' => { type: :flag },
          '--help' => { type: :flag },
        },
        '--interactive' => { type: :enum, values: %w[yes no] },
        '--help' => { type: :flag },
        '-h' => { type: :flag }
      }
    end

    subject do
      HammerCLI::Bash::Completion.new(JSON.load(dict.to_json))
    end

    it 'returns options when no input given' do
      result = subject.complete('').sort
      _(result).must_equal ['host ', '--interactive ', '--help ', '-h '].sort
    end

    it 'returns filtered options when partial input is given' do
      result = subject.complete('-').sort
      _(result).must_equal ['--help ', '-h ', '--interactive '].sort
    end

    it 'returns filtered options when partial input is given' do
      result = subject.complete('host')
      _(result).must_equal ['host ']
    end

    it 'returns options when subcommand is given' do
      result = subject.complete('host ').sort
      _(result).must_equal ['create ', '--help ', '--dry '].sort
    end

    it 'returns no options when subcommand is wrong' do
      result = subject.complete('unknown -h')
      _(result).must_equal []
    end

    it 'returns no options when there are no other params allowed' do
      result = subject.complete('host create /tmp some /tmp extra')
      _(result).must_equal []
    end

    it 'return hint for option-value pair without value' do
      result = subject.complete('host create -t ')
      _(result).must_equal ['--->', 'Add option <value>']
    end

    it 'return no options for option-value pair without complete value' do
      result = subject.complete('host create -t x')
      _(result).must_equal []
    end

    # multiple options in one subcommand
    it 'allows mutiple options of the same subcommand' do
      result = subject.complete('host create --build --he')
      _(result).must_equal ['--help ']
    end

    # multiple options with values in one subcommand
    it 'allows mutiple options with values of the same subcommand' do
      result = subject.complete('host create -t value --he')
      _(result).must_equal ['--help ']
    end

    # subcommand after options
    it 'allows subcommand after options' do
      result = subject.complete('host --dry crea')
      _(result).must_equal ['create ']
    end

    describe 'completion by type' do
      it 'completes :value' do
        result = subject.complete('host create -t ')
        _(result).must_equal ['--->', 'Add option <value>']
      end

      it 'completes :flag' do
        result = subject.complete('host --h')
        _(result).must_equal ['--help ']
      end

      it 'completes :schema' do
        result = subject.complete('host create --installed-products-attributes ')
        _(result).must_equal ["--->", 'Add value by following schema: "product_id=string\,product_name=string\,arch=string\,version=string, ... "']
      end

      it 'completes :enum' do
        result = subject.complete('host create --managed ')
        _(result).must_equal ['yes ', 'no ']
      end

      it 'completes :multienum' do
        result = subject.complete('host create --volume ')
        _(result).must_equal ['first', 'second', 'third']

        result = subject.complete('host create --volume fir')
        _(result).must_equal ['first']

        result = subject.complete('host create --volume first,')
        _(result).must_equal ['second', 'third']

        result = subject.complete('host create --volume first,se')
        _(result).must_equal ['first,second']
      end

      it 'completes :list' do
        result = subject.complete('host create --config-group-ids ')
        _(result).must_equal ['--->', 'Add comma-separated list of values']
      end

      it 'completes :key_value_list' do
        result = subject.complete('host create --params ')
        _(result).must_equal ['--->', 'Add comma-separated list of key=value']
      end
    end
  end
end
