require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Help::Builder do
  let(:help) { HammerCLI::Help::Builder.new }

  describe 'sorting options' do
    it 'prints options alphabetically sorted' do
      options = [
        Clamp::Option::Definition.new(['--zzz-option'], 'OPT_Z', 'Some description'),
        Clamp::Option::Definition.new(['--yyy-option'], 'OPT_Y', 'Some description'),
        Clamp::Option::Definition.new(['--aaa-option'], 'OPT_A', 'Some description'),
        Clamp::Option::Definition.new(['--bbb-option'], 'OPT_B', 'Some description')
      ]
      help.add_list('Options', options)

      help.string.strip.must_equal [
        'Options:',
        ' --aaa-option OPT_A            Some description',
        ' --bbb-option OPT_B            Some description',
        ' --yyy-option OPT_Y            Some description',
        ' --zzz-option OPT_Z            Some description'
      ].join("\n")
    end
  end

  describe 'adding an option with lower case description' do
    it 'capitalizes the description' do
      options = [
        Clamp::Option::Definition.new(['--alpha-option'], 'OPT_ALPHA', 'alpha description'),
        Clamp::Option::Definition.new(['--beta-option'], 'OPT_BETA', 'BETA description')
      ]
      help.add_list('Options',options)

      help.string.strip.must_equal [
        'Options:',
        ' --alpha-option OPT_ALPHA      Alpha description',
        ' --beta-option OPT_BETA        BETA description'
      ].join("\n")
    end
  end

  describe 'adding text' do
    let(:content_1) {[
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      'Donec sem dolor, pellentesque sit amet auctor nec, finibus ut elit.'
    ]}
    let(:content_2) {[
      'Donec et erat in enim pellentesque pretium. Sed egestas sem id lectus ultricies lobortis.',
      'Etiam posuere, ipsum scelerisque maximus fermentum, libero dui sagittis felis, at molestie erat augue at dui. Ut dapibus rutrum purus a luctus.'
    ]}

    it 'prints paragraphs without headings' do
      help.add_text(content_1.join("\n"))
      help.string.strip.must_equal content_1.join("\n")
    end

    it 'prints paragraphs with headings' do
      help.add_text(content_1.join("\n"))
      help.string.strip.must_equal content_1.join("\n")
    end

    it 'prints multiple paragraphs divided with empty line' do
      help.add_text(content_1.join("\n"))
      help.add_text(content_2.join("\n"))

      expected_output = content_1 + [''] + content_2
      expected_output = expected_output.join("\n")

      help.string.strip.must_equal expected_output
    end
  end
end
