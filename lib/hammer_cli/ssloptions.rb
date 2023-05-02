module HammerCLI
  class SSLOptions
    DEFAULT_LOCAL_CA_STORE_PATH = "~/.hammer/certs"

    def initialize(options={})
      @settings = options.fetch(:settings, HammerCLI::Settings)
      @logger = options.fetch(:logger, Logging.logger['SSLoptions'])
      @ca_manager = options.fetch(:ca_manager, HammerCLI::CACertManager.new(DEFAULT_LOCAL_CA_STORE_PATH))
    end

    def get_local_ca_store_path
      @settings.get(:ssl, :local_ca_store_path) || DEFAULT_LOCAL_CA_STORE_PATH
    end

    def get_options(uri = nil)
      ssl_options = {}
      for sslopt in [:ssl_ca_file, :ssl_ca_path, :verify_ssl, :ssl_version] do
        ssloptval = read_ssl_option(sslopt)
        ssl_options[sslopt] = ssloptval unless ssloptval.nil?
      end
      ssl_options.merge!(cert_key_options)

      # enable ssl verification
      ssl_options[:verify_ssl] = true if ssl_options[:verify_ssl].nil?

      if ssl_options[:verify_ssl] && uri && !ssl_options[:ssl_ca_file] && !ssl_options[:ssl_ca_path]
        uri = URI.parse(uri) if uri.is_a?(String)
        if @ca_manager.cert_exist?(uri)
          ssl_options[:ssl_ca_file] = @ca_manager.cert_file_name(uri)
          @logger.info("Matching CA cert was found in local CA store #{ssl_options[:ssl_ca_file]}")
        end
      end

      [:ssl_ca_file, :ssl_ca_path].each do |opt|
        ssl_options[opt] = File.expand_path(ssl_options[opt]) unless ssl_options[opt].nil?
      end

      @logger.debug("SSL options: #{ApipieBindings::Utils::inspect_data(ssl_options)}")
      ssl_options
    end

    protected

    def read_ssl_option(key)
      @settings.get(:_params, key).nil? ? @settings.get(:ssl, key) : @settings.get(:_params, key)
    end

    def cert_key_options
      options = {
        :ssl_client_cert => read_certificate(read_ssl_option(:ssl_client_cert)),
        :ssl_client_key => read_key(read_ssl_option(:ssl_client_key))
      }

      if options[:ssl_client_cert] && options[:ssl_client_key]
        options
      elsif options[:ssl_client_cert] || options[:ssl_client_key]
        if options[:ssl_client_cert]
          warn _("SSL client certificate is set but the key is not.")
        elsif options[:ssl_client_key]
          warn _("SSL client key is set but the certificate is not.")
        end
        warn _("SSL client authentication disabled.")
        {}
      else
        {}
      end
    end

    def read_certificate(path)
      OpenSSL::X509::Certificate.new(File.read(path)) unless path.nil?
    rescue SystemCallError
      warn _("Could't read SSL client certificate %s.") % path
    end

    def read_key(path)
      OpenSSL::PKey.read(File.read(path)) unless path.nil?
    rescue SystemCallError
      warn _("Could't read SSL client key %s.") % path
    end
  end
end
