require 'hammer_cli/ca_cert_manager'
module HammerCLI
  class CACertFetcher
    def fetch_ca_cert(service_uri, ca_store_path)
      begin
        uri = URI.parse(service_uri)
        raise URI::InvalidURIError.new(_("Unable to find hostname in #{service_uri}")) if uri.host.nil?
        raise URI::InvalidURIError.new(scheme_error(uri)) unless uri.scheme == 'https'
        ca_cert_manager = HammerCLI::CACertManager.new(ca_store_path)
        raw_cert = HammerCLI::CertDownloader.new.download(uri)
        cert_file = ca_cert_manager.cert_file_name(uri)
        ca_cert_manager.store_ca_cert(raw_cert, cert_file)

        rh_install_path = "/etc/pki/ca-trust/source/anchors/"
        rh_update_cmd = "update-ca-trust"
        deb_install_path = "/usr/local/share/ca-certificates/"
        deb_update_cmd = "update-ca-certificates"
        cert_file = ca_cert_manager.cert_file_name(uri)

        puts _("CA certificate for #{service_uri} was stored to #{cert_file}")
        puts _("Now hammer can use the downloaded certificate to verify SSL connection to the server.")
        puts _("It will be used automatically when ssl_ca_path and ssl_ca_file options are not set.")
        puts
        puts _("Be aware that hammer cannot verify whether the certificate is correct and you should verify its authenticity.")
        puts
        puts _("You can display the certificate content with")
        puts "  $ openssl x509 -text -in #{cert_file}"
        puts

        cert_install_msg = _("As root you can also install the certificate and update the system-wide list of trusted CA certificates as follows:") + "\n"

        if File.directory?(rh_install_path)
          puts cert_install_msg
          puts "  $ install #{cert_file} #{rh_install_path}"
          puts "  $ #{rh_update_cmd}"
        elsif File.directory?(deb_install_path)
          puts cert_install_msg
          puts "  $ install #{cert_file} #{deb_install_path}"
          puts "  $ #{deb_update_cmd}"
        end
        puts
        return HammerCLI::EX_OK

      rescue URI::InvalidURIError => e
        $stderr.puts _("Couldn't parse URI '%s'.") % service_uri
        $stderr.puts e.message
        return HammerCLI::EX_SOFTWARE
      rescue HammerCLI::NoCACertificate => e
        $stderr.puts _("The CA certificate for #{service_uri} couldn't be downloaded. No CA cert was found.")
        $stderr.puts
        $stderr.puts _("Make sure your server sends cert chain including the CA.")
        $stderr.puts _("To see the actual chain you can use openssl command")
        $stderr.puts "  $ openssl s_client -showcerts -connect #{uri.host}:#{uri.port} </dev/null"
        $stderr.puts
        $stderr.puts _("You can also download the certificate manually and store it as #{cert_file}")
        $stderr.puts _("If you choose any other location set the ssl_ca_path or ssl_ca_file configuration options appropriately.")
        return HammerCLI::EX_SOFTWARE
      rescue StandardError => e
        logger = Logging.logger['CACertFetcher']
        msg = [_('Fetching the CA certificate failed:')]

        if e.is_a?(OpenSSL::SSL::SSLError) && e.message.include?('unknown protocol')
          msg << _('The service at the given URI does not accept SSL connections')
          msg << scheme_error if uri.scheme == 'http'
        else
          msg << e.message
        end
        $stderr.puts msg.join("\n")
        logger.error(e.backtrace.join("\n    "))
        return HammerCLI::EX_SOFTWARE
      end
    end

    private

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
  end
end
