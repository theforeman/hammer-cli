require 'tmpdir'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli/ca_cert_manager'

describe HammerCLI::CACertManager do

  before(:all) do
    @ca_store_path = Dir.mktmpdir('ca_cert_manager')
  end

  after(:all) do
    FileUtils.rm_rf(@ca_store_path) if File.exist?(@ca_store_path)
  end

  let(:service_uri) { URI.parse("https://test.host.com") }
  let(:ca_cert_manager) { HammerCLI::CACertManager.new(@ca_store_path) }
  let(:cert_file) { ca_cert_manager.cert_file_name(service_uri) }
  let(:cert_fixture) { File.join(File.dirname(__FILE__), '/fixtures/certs/ca_cert.pem') }

  describe '#store_ca_cert' do
    it 'stores ca cert' do
      new_cert_file = ca_cert_manager.store_ca_cert(File.read(cert_fixture), cert_file)
      assert File.exist?(cert_file)
      assert_equal cert_file, new_cert_file
    end
  end

  describe '#cert_exist?' do
    it 'return true if the cert exist' do
      ca_cert_manager.store_ca_cert(File.read(cert_fixture), cert_file)
      assert ca_cert_manager.cert_exist?(service_uri)
    end

    it 'return false if the cert does not exist' do
      refute ca_cert_manager.cert_exist?(service_uri)
    end
  end

  describe '#cert_file_name' do
    it 'make file name from host uri' do
      uri = URI.parse("https://test.example.com:1111")
      filename = ca_cert_manager.cert_file_name(uri)
      assert_equal File.join(ca_cert_manager.ca_store_path,'test.example.com_1111.pem'), filename
    end
  end
end
