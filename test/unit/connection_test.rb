require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::Connection do
  let(:connections) { HammerCLI::Connection.new }

  describe '#create' do
    it "creates new connection" do
      connections.create(:test) do
        :conn1
      end
      assert_equal :conn1, connections.get(:test)
    end

    it "doesn't overwrite the connection when called multiple times" do
      connections.create(:test) do
        :conn1
      end
      connections.create(:test) do
        :conn2
      end
      assert_equal :conn1, connections.get(:test)
    end

    it 'writes message to log' do
      logger = stub()
      logger.expects(:debug).with('Registered: test_connection')

      connections = HammerCLI::Connection.new(logger)
      connections.create(:test_connection) do
        :test_connection
      end
    end
  end

  describe '#drop' do
    it 'drops the connection' do
      connections.create(:test) do
        :conn1
      end
      connections.drop(:test)
      assert_nil connections.get(:test)
    end
  end

  describe '#drop_all' do
    it 'drops all connections' do
      connections.create(:test1) do
        :conn1
      end
      connections.create(:test2) do
        :conn3
      end
      connections.drop_all

      assert_nil connections.get(:test1)
      assert_nil connections.get(:test2)
    end
  end
end
