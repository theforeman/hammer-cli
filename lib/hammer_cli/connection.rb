module HammerCLI

  class AbstractConnector
    def initialize(params={})
    end
  end

  class AbstractCredentialsGetter
    def get(creds, params)
      raise NotImplemented.new
    end
  end

  class AskPass < AbstractCredentialsGetter

    def get(service, creds, params)
      creds[:username] ||= params[:username]
      creds[:password] ||= params[:password]

      if HammerCLI.interactive?
        # username
        unless params[:username]
          creds[:username] ||= ask_user("[#{service}] username: ")
        end
        unless params[:password]
          creds[:password] ||= ask_user("[#{service}] password for #{creds[:username]}: ", :silent => true)
        end
      end
      creds
    end

    private

    def ask_user(prompt, options={})
      silent = options.has_key?(:silent) ? options[:silent] : false
      if silent
        ask(prompt) {|q| q.echo = false}
      else
        ask(prompt)
      end
    end

  end


  class Connection

    def self.drop_all()
      connections.keys.each { |c| drop(c) }
    end

    def self.clean_all()
      drop_all
      clean_all_credentials
    end

    def self.get(name, params={}, options={})
      unless connections[name]
        Logging.logger['Connection'].debug "Registered: #{name}"
        connector = options[:connector] || AbstractConnector
        service = options[:service] || name
        credentials_getter = options[:credentials_getter] || AskPass.new

        credentials[service] ||= {}
        credentials[service] = credentials_getter.get(service, credentials[service], params)
        credentials[service].each { |key, val| params[key] = val }

        connections[name] = connector.new(params)
      end
      connections[name]
    end

    def self.drop(name)
      connections.delete(name)
    end

    def self.clean_all_credentials()
      credentials.keys.each { |c| clean_credentials(c) }
    end

    def self.clean_credentials(name)
      credentials.delete(name)
    end


    def self.credentials
      @credentials_hash ||= {}
      @credentials_hash
    end

    private

    def self.connections
      @connections_hash ||= {}
      @connections_hash
    end

  end
end
