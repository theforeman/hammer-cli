module HammerCLI
  class CACertFetcher
    def self.fetch_ca_cert(host)
      CACertFetcher.new.fetch_ca_cert(host)
    end

    def fetch_ca_cert(host)
      begin
        uri = URI.parse(host)

        hostname = uri.host
        port = uri.port || 443

        if hostname.nil?
          $stderr.puts _("Couldn't parse URI '%s'.") % host
          $stderr.puts scheme_error(uri)
          return HammerCLI::EX_SOFTWARE
        end

        puts get_ca_cert(hostname, port)
        return HammerCLI::EX_OK
      rescue StandardError => e
        msg = [_('Fetching the CA certificate failed:')]

        if e.is_a?(OpenSSL::SSL::SSLError) && e.message.include?('unknown protocol')
          msg << _('The service at the given URI does not accept SSL connections')
          msg << scheme_error(uri) if uri.scheme == 'http'
        else
          msg << e.message
        end
        $stderr.puts msg.join("\n")
        return HammerCLI::EX_SOFTWARE
      end
    end

    protected

    def scheme_error(uri)
      _("Perhaps you meant to connect to '%s'?") % uri_to_https(uri)
    end

    def uri_to_https(uri)
      https_uri = uri.to_s
      if uri.scheme == 'http'
        # Scheme is http, replace with https.
        https_uri = https_uri.sub(/^http/, 'https')
      elsif uri.scheme.nil? || !https_uri.match(/:\/\//)
        # Scheme either wasn't recognized or host was parsed into scheme.
        # That can happen when user enters '<host>:<port>' without scheme.
        https_uri = "https://#{https_uri}"
      end
      https_uri
    end

    def get_ca_cert(hostname, port)
      noverify_ssl_connection = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(hostname, port), noverify_ssl_context)
      noverify_ssl_connection.connect
      noverify_ssl_connection.peer_cert_chain.last
    end

    def noverify_ssl_context
      noverify_ssl_context = OpenSSL::SSL::SSLContext.new
      noverify_ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      noverify_ssl_context
    end
  end
end
