module HammerCLI
  class SSLOptions
    DEFAULT_SSL_CA_PATH = "~/.hammer/certs"

    def initialize(settings = HammerCLI::Settings, logger = Logging.logger['SSLoptions'])
      @settings = settings
      @logger = logger
    end

    def self.get_options(settings = HammerCLI::Settings, logger = Logging.logger['SSLoptions'])
      self.new(settings, logger).get_options
    end

    def get_options
      ssl_options = {}
      for sslopt in [:ssl_ca_file, :ssl_ca_path, :verify_ssl] do
        ssloptval = read_ssl_option(sslopt)
        ssl_options[sslopt] = ssloptval unless ssloptval.nil?
      end
      ssl_options.merge!(cert_key_options)

      ssl_options[:ssl_ca_path] = DEFAULT_SSL_CA_PATH if ssl_options[:ssl_ca_path].nil?
      [:ssl_ca_file, :ssl_ca_path].each do |opt|
        ssl_options[opt] = File.expand_path(ssl_options[opt]) unless ssl_options[opt].nil?
      end

      # enable ssl verification
      ssl_options[:verify_ssl] = true if ssl_options[:verify_ssl].nil?
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
          warn _("SSL client certificate is set but the key is not")
        elsif options[:ssl_client_key]
          warn _("SSL client key is set but the certificate is not")
        end
        warn _("SSL client authentication disabled")
        {}
      else
        {}
      end
    end

    def read_certificate(path)
      OpenSSL::X509::Certificate.new(File.read(path)) unless path.nil?
    rescue SystemCallError => e
      warn _("Could't read SSL client certificate %s") % path
    end

    def read_key(path)
      OpenSSL::PKey::RSA.new(File.read(path)) unless path.nil?
    rescue SystemCallError => e
      warn _("Could't read SSL client key %s") % path
    end
  end
end
