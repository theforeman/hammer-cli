require 'tmpdir'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli/ca_cert_manager'

describe HammerCLI::CACertManager do

  before(:all) do
    @ca_path = Dir.mktmpdir('ca_cert_manager')
  end

  after(:all) do
    FileUtils.rm_rf(@ca_path) if File.exist?(@ca_path)
  end

  let(:service_uri) { URI.parse("https://test.host.com") }
  let(:ca_cert_manager) { HammerCLI::CACertManager.new(@ca_path) }
  let(:cert_file) { ca_cert_manager.cert_file_name(service_uri) }

  describe '#store_ca_cert' do
    let(:cert_fixture) { File.join(File.dirname(__FILE__), '/fixtures/certs/ca_cert.pem') }

    it 'stores ca cert' do
      new_cert_file = ca_cert_manager.store_ca_cert(File.read(cert_fixture), cert_file)
      assert File.exist?(File.join(@ca_path, "2c543cd1.0"))
      assert File.exist?(cert_file)
      assert_equal cert_file, new_cert_file
    end
  end

  describe '#create_link' do
    let(:hash) { 123456789 }
    let(:hash_file) { hash.to_s(16) }

    it "creates link to cert" do
      FileUtils.touch(cert_file)
      ca_cert_manager.create_link(hash, cert_file)
      assert File.exist?(File.join(@ca_path, "#{hash_file}.0"))
    end

    it "creates ca path if missing" do
      FileUtils.rm_rf(@ca_path) if File.exist?(@ca_path)
      ca_cert_manager.create_link(hash, cert_file)
      FileUtils.touch(cert_file)
      assert File.exist?(File.join(@ca_path, "#{hash_file}.0"))
    end

    it "does not create new link if it already exist" do
      FileUtils.touch(cert_file)
      File.symlink(cert_file, File.join(@ca_path, "#{hash_file}.0"))
      ca_cert_manager.create_link(hash, cert_file)
      assert File.exist?(File.join(@ca_path, "#{hash_file}.0"))
      refute File.exist?(File.join(@ca_path, "#{hash_file}.1"))
    end

    it "does not override existing link if it has different target" do
      FileUtils.touch(cert_file)
      FileUtils.touch(File.join(@ca_path, "#{hash_file}.0"))
      ca_cert_manager.create_link(hash, cert_file)
      assert File.exist?(File.join(@ca_path, "#{hash_file}.0"))
      assert File.exist?(File.join(@ca_path, "#{hash_file}.1"))
    end
  end
end
