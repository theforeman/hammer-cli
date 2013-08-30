require File.join(File.dirname(__FILE__), 'test_helper')


describe HammerCLI::ExceptionHandler do

  before(:each) do
    @log_output = Logging::Appenders['__test__']
    @log_output.reset
  end

  let(:output) { HammerCLI::Output::Output.new }
  let(:handler) { HammerCLI::ExceptionHandler.new :output => output }
  let(:heading) { "Something went wrong" }

  it "should handle unauthorized" do
    output.expects(:print_error).with(heading, "Invalid username or password")
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

  it "should handle resource not found" do
    ex = RestClient::ResourceNotFound.new
    output.expects(:print_error).with(heading, ex.message)
    handler.handle_exception(ex, :heading => heading)
  end

  it "should log the error" do 
    ex = RestClient::ResourceNotFound.new
    output.stubs(:print_error).returns('')
    handler.handle_exception(ex)
    @log_output.readline.strip.must_equal 'ERROR  Exception : Resource Not Found'
  end 

end

