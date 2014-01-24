module HammerCLI

  class AbstractConnector
    def initialize(params={})
    end
  end

  class Connection

    def self.drop(name)
      connections.delete(name)
    end

    def self.drop_all()
      connections.keys.each { |c| drop(c) }
    end

    def self.create(name, conector_params={}, options={})
      unless connections[name]
        Logging.logger['Connection'].debug "Registered: #{name}"
        connector = options[:connector] || AbstractConnector

        connections[name] = connector.new(conector_params)
      end
      connections[name]
    end

    def self.exist?(name)
      get(name).nil?
    end

    def self.get(name)
      connections[name]
    end

    private

    def self.connections
      @connections_hash ||= {}
      @connections_hash
    end

  end
end
