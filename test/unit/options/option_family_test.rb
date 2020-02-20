require_relative '../test_helper'

describe HammerCLI::Options::OptionFamily do
  let(:family) do
    HammerCLI::Options::OptionFamily.new(
      deprecated: { '--test-one' => 'Use --test-two instead' }
    )
  end
  let(:first_option) { HammerCLI::Apipie::OptionDefinition.new("--test-one", '', '') }
  let(:second_option) { HammerCLI::Apipie::OptionDefinition.new("--test-two", '', '') }
  let(:third_option) { HammerCLI::Apipie::OptionDefinition.new("--test-three", '', '') }
  let(:full_family) do
    family.parent('--test-one', '', 'Test').family.child('--test-two', '', '').family
  end

  describe 'switch' do
    it 'returns nil if family is empty' do
      family.switch.must_be_nil
    end

    it 'returns parent switch if family has no children' do
      family.parent('--test-one', '', '')
      family.switch.must_equal '--test-one'
    end

    it 'returns switch based on members' do
      full_family.switch.must_equal '--test[-two|-one]'
    end
  end

  describe 'description' do
    it 'returns parent description if nothing passed to initializer' do
      full_family.description.must_equal full_family.head.help[1]
    end

    it 'returns description with deprecation message' do
      full_family.description.must_equal 'Test (--test-one is deprecated: Use --test-two instead)'
    end
  end

  describe 'adopt' do
    it 'appends an option to children' do
      full_family.adopt(third_option)
      full_family.children.size.must_equal 2
      third_option.family.must_equal full_family
    end
  end
end
