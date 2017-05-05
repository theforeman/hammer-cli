require File.join(File.dirname(__FILE__), 'test_helper')


describe HammerCLI::ExceptionHandler do

  before(:each) do
    @log_output = Logging::Appenders['__test__']
    @log_output.reset
  end

  let(:output) { HammerCLI::Output::Output.new }
  let(:handler) { HammerCLI::ExceptionHandler.new(:output => output)}
  let(:heading) { "Something went wrong" }
  let(:cmd) { Class.new(HammerCLI::AbstractCommand).new("command_name") }

  it "should handle unauthorized" do
    output.expects(:print_error).with(heading, "Unauthorized")
    handler.handle_exception(RestClient::Unauthorized.new, :heading => heading)
  end

  it "should handle general exception" do
    output.expects(:print_error).with(heading, "Error: message")
    handler.handle_exception(Exception.new('message'), :heading => heading)
  end

  it "should handle unknown exception" do
    output.expects(:print_error).with(heading, "Error: message")
    MyException = Class.new(Exception)
    handler.handle_exception(MyException.new('message'), :heading => heading)
  end

  it "should handle help request" do
    output.expects(:print_message).with(cmd.help)
    handler.handle_exception(Clamp::HelpWanted.new(cmd), :heading => heading)

  end

  it "should handle usage error" do
    output.expects(:print_error).with(heading, "Error: wrong_usage\n\nSee: 'command_name --help'")
    handler.handle_exception(Clamp::UsageError.new('wrong_usage', cmd), :heading => heading)

  end

  it "should handle resource not found" do
    ex = RestClient::ResourceNotFound.new
    output.expects(:print_error).with(heading, ex.message)
    handler.handle_exception(ex, :heading => heading)
  end

  it "should log the error" do
    ex = RestClient::ResourceNotFound.new
    output.default_adapter = :silent
    handler.handle_exception(ex)
    assert_match /Using exception handler HammerCLI::ExceptionHandler#handle_not_found/, @log_output.readline.strip
    assert_match /ERROR  Exception : (Resource )?Not Found/, @log_output.readline.strip
  end

end

