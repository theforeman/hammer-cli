module HammerCLI
  def self.get_ssl_options(settings = HammerCLI::Settings, logger = Logging.logger['SSLoptions'])
    ssl_options = {}
    for sslopt in [:ssl_ca_file, :ssl_ca_path, :verify_ssl] do
      ssloptval = read_ssl_option(settings, sslopt)
      ssl_options[sslopt] = ssloptval if ssloptval
    end
    ssl_options.merge!(cert_key_options(settings))

    # enable ssl verification if verify_ssl is not configured and either CA file or path are present
    ssl_options[:verify_ssl] = 1 if ssl_options[:verify_ssl].nil? && (ssl_options[:ssl_ca_file] || ssl_options[:ssl_ca_path])
    logger.debug("SSL options: #{ApipieBindings::Utils::inspect_data(ssl_options)}")
    ssl_options
  end

  def self.read_ssl_option(settings, key)
    settings.get(:_params, key) || settings.get(:ssl, key)
  end

  def self.cert_key_options(settings)
    options = {
      :ssl_client_cert => read_certificate(read_ssl_option(settings, :ssl_client_cert)),
      :ssl_client_key => read_key(read_ssl_option(settings, :ssl_client_key))
    }

    if options[:ssl_client_cert] && options[:ssl_client_key]
      options
    else
      if options[:ssl_client_cert]
        warn _("SSL client certificate is set but the key is not, SSL client authentication disabled")
      elsif options[:ssl_client_key]
        warn _("SSL client key is set but the certificate is not, SSL client authentication disabled")
      end
      {}
    end
  end

  def self.read_certificate(path)
    OpenSSL::X509::Certificate.new(File.read(path)) unless path.nil?
  rescue SystemCallError => e
    warn _("Could't read SSL client certificate %s, SSL client authentication disabled") % path
  end

  def self.read_key(path)
    OpenSSL::PKey::RSA.new(File.read(path)) unless path.nil?
  rescue SystemCallError => e
    warn _("Could't read SSL client key %s, SSL client authentication disabled") % path
  end
end
