module HammerCLI

  class AbstractConnector
    def initialize(params={})
    end
  end

  class Connection
    def initialize(logger = nil)
      @logger = logger
    end

    def drop(name)
      connections.delete(name)
    end

    def drop_all()
      connections.keys.each { |c| drop(c) }
    end

    def create(name, &create_connector_block)
      unless connections[name]
        connector = yield
        @logger.debug("Registered: #{name}") if @logger
        connections[name] = connector
      end
      connections[name]
    end

    def exist?(name)
      !get(name).nil?
    end

    def get(name)
      connections[name]
    end

    def available
      connections.select { |k, v| !v.nil? }.values.first
    end

    private

    def connections
      @connections_hash ||= {}
      @connections_hash
    end
  end
end
