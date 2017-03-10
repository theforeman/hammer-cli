module HammerCLI
  def self.get_ssl_options(settings = HammerCLI::Settings, logger = Logging.logger['SSLoptions'])
    ssl_options = {}
    for sslopt in [:ssl_ca_file, :ssl_ca_path] do
      ssloptval = settings.get(:_params, sslopt) || settings.get(:ssl, sslopt)
      ssl_options[sslopt] = ssloptval if ssloptval
    end
    ssl_client_cert = settings.get(:_params, :ssl_client_cert) || settings.get(:ssl, :ssl_client_cert)
    ssl_client_key = settings.get(:_params, :ssl_client_key) || settings.get(:ssl, :ssl_client_key)
    if ssl_client_cert && ssl_client_key
      ssl_options[:ssl_client_cert] = OpenSSL::X509::Certificate.new(File.read(ssl_client_cert))
      ssl_options[:ssl_client_key] = OpenSSL::PKey::RSA.new(File.read(ssl_client_key))
    elsif ssl_client_cert
      warn _("SSL client certificate is set but the key is not, SSL client authentication disabled")
    elsif ssl_client_key
      warn _("SSL client key is set but the certificate is not, SSL client authentication disabled")
    end
    verify_ssl = settings.get(:_params, :verify_ssl) || settings.get(:ssl, :verify_ssl)
    ssl_options[:verify_ssl] = verify_ssl unless verify_ssl.nil?
    # enable ssl verification if verify_ssl is not configured and either CA file or path are present
    ssl_options[:verify_ssl] = 1 if ssl_options[:verify_ssl].nil? && (ssl_options[:ssl_ca_file] || ssl_options[:ssl_ca_path])
    logger.debug("SSL options: #{ApipieBindings::Utils::inspect_data(ssl_options)}")
    ssl_options
  end
end
