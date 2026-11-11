require File.join(File.dirname(__FILE__), 'test_helper')
require 'tmpdir'
require 'hammer_cli/i18n/find_task'

describe HammerCLI::I18n::FindTask do
  before do
    @previous_rake_application = Rake.application
    Rake.application = Rake::Application.new
  end

  after do
    Rake.application = @previous_rake_application
  end

  def run_find_new(locale_dir, stats)
    domain = Struct.new(:locale_dir, :domain_name).new(locale_dir, 'hammer-cli')
    client = mock
    HammerCLI::TaskHelper::I18n::TxApiClient.expects(:new).with(domain: domain).returns(client)
    client.expects(:language_stats_collection).returns('data' => stats)
    HammerCLI::I18n::FindTask.define(domain, '1.0')
    Rake::Task['gettext:find_new'].invoke
  end

  def language_stats(lang, translated, total)
    { 'id' => "resource:#{lang}", 'attributes' => { 'translated_strings' => translated, 'total_strings' => total } }
  end

  it 'preserves an existing catalog for a qualifying language' do
    Dir.mktmpdir do |locale_dir|
      File.write(File.join(locale_dir, 'hammer-cli.pot'), 'template contents')
      lang_dir = File.join(locale_dir, 'fr')
      FileUtils.mkdir_p(lang_dir)
      po_file = File.join(lang_dir, 'hammer-cli.po')
      File.write(po_file, 'existing translation')

      run_find_new(locale_dir, [language_stats('fr', 80, 100)])

      _(File.read(po_file)).must_equal 'existing translation'
    end
  end

  it 'creates a catalog from the template for a new qualifying language' do
    Dir.mktmpdir do |locale_dir|
      File.write(File.join(locale_dir, 'hammer-cli.pot'), 'template contents')

      run_find_new(locale_dir, [language_stats('de', 50, 100), language_stats('es', 49, 100)])

      _(File.read(File.join(locale_dir, 'de', 'hammer-cli.po'))).must_equal 'template contents'
      _(File.exist?(File.join(locale_dir, 'es', 'hammer-cli.po'))).must_equal false
    end
  end
end
