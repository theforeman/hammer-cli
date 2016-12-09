require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLI::Apipie::ApiConnection do
  let(:connection) { HammerCLI::Connection.new }

  describe '#initialize' do

    let(:empty_params) {{}}

    def api_stub(params = {})
      api_stub = stub()
      ApipieBindings::API.expects(:new).with(params).returns(api_stub)
      api_stub
    end

    it "passes attributes to apipie bindings" do
      params = { :apidoc_cache_name => 'test.example.com' }

      api_stub(params)
      HammerCLI::Apipie::ApiConnection.new(params)
    end

    context "with :clear_cache => true" do
      it "clears cache" do
        api_stub.expects(:clean_cache)
        HammerCLI::Apipie::ApiConnection.new(empty_params, :reload_cache => true)
      end

      it "logs message when logger is available" do
        logger = stub()
        logger.expects(:debug).with('Apipie cache was cleared')

        api_stub.expects(:clean_cache)
        HammerCLI::Apipie::ApiConnection.new(empty_params, :reload_cache => true, :logger => logger)
      end
    end
  end
end
