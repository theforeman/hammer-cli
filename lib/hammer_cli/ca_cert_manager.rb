require 'fileutils'

module HammerCLI
  class CACertManager
    attr_reader :ca_store_path

    def initialize(ca_store_path)
      @ca_store_path = File.expand_path(ca_store_path)
    end

    def store_ca_cert(raw_cert, cert_file)
      ensure_ca_store_exist
      File.write(cert_file, raw_cert)
      cert_file
    end

    def cert_file_name(uri)
      File.join(ca_store_path, "#{uri.host}_#{uri.port}.pem")
    end

    def cert_exist?(uri)
      File.exist?(cert_file_name(uri))
    end

    protected

    def ensure_ca_store_exist
      FileUtils.mkpath(ca_store_path) unless File.directory?(ca_store_path)
    end
  end

  class CACertDownloader
    def download(uri)
      noverify_ssl_connection = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(uri.host, uri.port), noverify_ssl_context)
      noverify_ssl_connection.connect
      noverify_ssl_connection.peer_cert_chain.last
    end

    private

    def noverify_ssl_context
      noverify_ssl_context = OpenSSL::SSL::SSLContext.new
      noverify_ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      noverify_ssl_context
    end
  end
end
