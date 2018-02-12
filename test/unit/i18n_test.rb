require File.join(File.dirname(__FILE__), 'test_helper')


describe HammerCLI::I18n do

  class TestLocaleDomain < HammerCLI::I18n::AbstractLocaleDomain

    def initialize(name, available)
      @name = name
      @available = available
    end

    def locale_dir
      File.dirname(__FILE__)
    end

    def domain_name
      @name
    end

    def available?
      @available
    end
  end

  let(:fast_gettext_version) { '1.2.0' }

  before do
    @domains_backup ||= HammerCLI::I18n.domains.dup
    HammerCLI::I18n.stubs(:fast_gettext_version).returns(fast_gettext_version)
    HammerCLI::I18n.init
  end

  after do
    mocha_teardown
    HammerCLI::I18n.init(@domains_backup)
  end

  let(:domain1) { TestLocaleDomain.new('domain1', true) }
  let(:domain2) { TestLocaleDomain.new('domain2', true) }
  let(:unavailable_domain) { TestLocaleDomain.new('domain3', false) }

    describe "with fast_gettext >= 1.2.0" do
      it "creates base merge repository" do
        HammerCLI::I18n.translation_repository.class.must_equal FastGettext::TranslationRepository::Merge
        HammerCLI::I18n.translation_repository.expects(:add_repo).with(repo)
    end

    it "registers available domains at gettext" do
      repo = mock
      FastGettext::TranslationRepository.expects(:build).with(domain1.domain_name,
        :path => domain1.locale_dir,
        :type => domain1.type,
        :report_warning => false).returns(repo)

      HammerCLI::I18n.add_domain(domain1)
    end

    it "skips registering domains that are not available" do
      HammerCLI::I18n.add_domain(domain1)
      HammerCLI::I18n.add_domain(domain2)
      HammerCLI::I18n.add_domain(unavailable_domain)
      HammerCLI::I18n.domains.must_equal [domain1, domain2]
    end
  end
end

