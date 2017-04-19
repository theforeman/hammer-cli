require 'fileutils'

module HammerCLI
  class CACertManager
    attr_reader :ca_path

    def initialize(ca_path)
      @ca_path = ca_path
    end

    def store_ca_cert(raw_cert, cert_file)
      ensure_ca_path_exist
      File.write(cert_file, raw_cert)
      hash = cert_hash(raw_cert)
      create_link(hash, cert_file)
      cert_file
    end

    def cert_hash(raw_cert)
      cert = OpenSSL::X509::Certificate.new(raw_cert)
      subject = OpenSSL::X509::Name.new(cert.subject)
      subject.hash
    end

    def create_link(hash, cert_file)
      ensure_ca_path_exist
      cert_link = File.join(ca_path, "#{hash.to_s(16)}.%s")
      count = 0
      # increase hash index if file or link to different target already exist
      while plain_file?(cert_link % count) || link_to_different_target?(cert_link % count, cert_file) do
        count += 1
      end
      File.symlink(cert_file, cert_link % count) unless File.symlink?(cert_link % count)
    end

    def cert_file_name(uri)
      File.join(ca_path, "#{uri.host}.pem")
    end

    protected


    def ensure_ca_path_exist
      FileUtils.mkpath(ca_path) unless File.directory?(ca_path)
    end

    def plain_file?(path)
      File.exist?(path) && !File.symlink?(path)
    end

    def link_to_different_target?(path, target)
      File.symlink?(path) && File.expand_path(File.readlink(path)) != File.expand_path(target)
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
