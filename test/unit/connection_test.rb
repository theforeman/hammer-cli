require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::Connection do

  before :each do
    # clean up global settings
    HammerCLI::Connection.drop_all
    HammerCLI::Settings.load({:_params => {:interactive => false}})
  end

  let(:connection) { HammerCLI::Connection }

  class Connector < HammerCLI::AbstractConnector

    attr_reader :url

    def initialize(params)
      @url = params[:url]
      super
    end

  end

  it "should return the conection" do
    conn = connection.create(:test, {})
    conn.must_be_kind_of HammerCLI::AbstractConnector
  end

  it "should create the connection only once" do
    conn1 = connection.create(:test, {})
    conn2 = connection.create(:test, {})
    conn1.must_equal conn2
  end

  it "should test the connection" do
    connection.exist?(:test).must_equal false
    conn1 = connection.create(:test, {})
    connection.exist?(:test).must_equal true
  end

it "should get the connection" do
    conn1 = connection.create(:test, {})
    conn2 = connection.get(:test)
    conn1.must_equal conn2
  end


  it "should be able to drop all" do
    conn1 = connection.create(:test, {})
    connection.drop_all
    conn2 = connection.create(:test, {})
    conn1.wont_equal conn2    # TODO
  end

  it "should drop the connection" do
    conn1 = connection.create(:test, {})
    connection.drop(:test)
    conn2 = connection.create(:test, {})
    conn1.wont_equal conn2
  end

  it "should accept custom connector" do
    conn = connection.create(:test, {:url => 'URL'}, :connector => Connector)
    conn.must_be_kind_of Connector
    conn.url.must_equal 'URL'
  end

end
