require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::Connection do

  before :each do
    # clean up global settings
    HammerCLI::Connection.clean_all
    HammerCLI::Settings.load({:_params => {:interactive => false}})
    HammerCLI::AskPass.any_instance.stubs(:get).returns({ :username => 'admin', :password => 'changeme' })
  end

  let(:connection) { HammerCLI::Connection }

  class Connector < HammerCLI::AbstractConnector

    attr_reader :url, :username, :password

    def initialize(params)
      @url = params[:url]
      @username = params[:username]
      @password = params[:password]
      super
    end

  end

  it "should return the conection" do
    conn = connection.get(:test, {})
    conn.must_be_kind_of HammerCLI::AbstractConnector
  end

  it "should create the connection only once" do
    conn1 = connection.get(:test, {})
    conn2 = connection.get(:test, {})
    conn1.must_equal conn2
  end

  it "should be able to drop all" do
    conn1 = connection.get(:test, {})
    connection.drop_all
    conn2 = connection.get(:test, {})
    conn1.wont_equal conn2    # TODO
  end

  it "should drop the connection" do
    conn1 = connection.get(:test, {})
    connection.drop(:test)
    conn2 = connection.get(:test, {})
    conn1.wont_equal conn2
  end

  it "should accept custom connector" do
    conn = connection.get(:test, {:url => 'URL'}, :connector => Connector)
    conn.must_be_kind_of Connector
    conn.url.must_equal 'URL'
  end

  it "should be possible to share the credentials" do
    HammerCLI::Settings.load({:_params => {:interactive => true}})
    HammerCLI::AskPass.any_instance.unstub(:get)
    HammerCLI::AskPass.any_instance.stubs(:ask_user).returns('user', 'pass', nil, nil)
    conn = connection.get(:test, {}, :connector => Connector, :service => :foreman)
    conn2 = connection.get(:other, {}, :connector => Connector, :service => :foreman)
    conn2.username.must_equal 'user'
    conn2.password.must_equal 'pass'
  end
end


describe HammerCLI::AskPass do

  context "interactive mode" do

    before :each do
      HammerCLI::Settings.load({:_params => {:interactive => true}})
    end

    let(:ask){ HammerCLI::AskPass.new }

    it "should ask for username when not provided" do
      ask.stubs(:ask_user).returns('user')
      creds = ask.get('service', {}, {:password => 'xxx'})
      creds[:username].must_equal 'user'
    end

    it "should not ask the username when provided" do
      ask.stubs(:ask_user).returns('other_user')
      creds = ask.get('service', { :username => 'user'}, {:password => 'xxx'})
      creds[:username].must_equal 'user'
    end

    it "should ask for password when not provided" do
      ask.stubs(:ask_user).returns('pass')
      creds = ask.get('service', {}, {:username => 'xxx'})
      creds[:password].must_equal 'pass'
    end

    it "should not ask the password when provided" do
      ask.stubs(:ask_user).returns('other_pass')
      creds = ask.get('service', { :password => 'pass'}, {:username => 'user'})
      creds[:password].must_equal 'pass'
    end

  end


end
