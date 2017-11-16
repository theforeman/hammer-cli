require File.join(File.dirname(__FILE__), './test_helper')

describe 'setting options to nil' do

  class TestNilableCommand < HammerCLI::AbstractCommand
    option '--description', 'DESCRIPTION', 'Description'
    
    def execute
      option_name = HammerCLI.option_accessor_name('description')
      params = options
      present = params.has_key?(option_name)
      puts "present?: #{present}"
      puts "nil?: #{params[option_name].nil?}" if present
      puts "value: #{params[option_name]}" if present
      HammerCLI::EX_OK
    end
    
    build_options
  end
  
  def assert_key_val(key, value, actual_output)
    assert_cmd(success_result(FieldMatcher.new(key, value.to_s)), actual_output)
  end
  
  it 'accepts empty string' do
    result = run_cmd(['--description=""'], {}, TestNilableCommand)
    assert_key_val('present?', true, result)
    assert_key_val('nil?', false, result)
    assert_key_val('value', '', result)
  end

  it 'unset options are not included' do
    result = run_cmd([], {}, TestNilableCommand)
    assert_key_val('present?', false, result)
  end

  it 'accepts NIL value' do
    result = run_cmd(['--description=NIL'], {}, TestNilableCommand)
    assert_key_val('present?', true, result)
    assert_key_val('nil?', true, result)
  end
  
  it 'accepts NULL value defined in ENV' do
    ENV.stubs(:[]).with('HAMMER_NIL').returns('NULL')
    result = run_cmd(['--description=NULL'], {}, TestNilableCommand)
    assert_key_val('present?', true, result)
    assert_key_val('nil?', true, result)
  end

  it 'throws error when HAMMER_NIL is empty' do
    ENV.stubs(:[]).with('HAMMER_NIL').returns('')
    cmd = ['--description=NULL']
    expected_result = common_error_result(cmd, "Environment variable HAMMER_NIL can not be empty")
    result = run_cmd(cmd, {}, TestNilableCommand)
    assert_cmd(expected_result, result)
  end
  
  it 'does not interpret NIL value when the subst is redefined' do
    ENV.stubs(:[]).with('HAMMER_NIL').returns('NULL')
    result = run_cmd(['--description=NIL'], {}, TestNilableCommand)
    assert_key_val('present?', true, result)
    assert_key_val('nil?', false, result)
    assert_key_val('value', 'NIL', result)
  end
  
  it 'overrides defaults' do
      defaults = defaults_mock
      defaults.stubs(:defaults_settings).returns({ :description => { :value => 'description' }})
      context = { :defaults => defaults }
      result = run_cmd(['--description=NIL'], context, TestNilableCommand)
      assert_key_val('present?', true, result)
      assert_key_val('nil?', true, result)
  end
end

