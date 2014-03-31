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

  before :each do
    HammerCLI::I18n.clear
  end

  let(:domain1) { TestLocaleDomain.new('domain1', true) }
  let(:domain2) { TestLocaleDomain.new('domain2', true) }
  let(:unavailable_domain) { TestLocaleDomain.new('domain3', false) }

  it "registers available domains at gettext" do
    FastGettext.expects(:add_text_domain).with do |name, options|
      (name == domain1.domain_name) && (options[:path] == domain1.locale_dir) && (options[:type] == domain1.type)
    end
    HammerCLI::I18n.add_domain(domain1)
  end

  it "skips registering domains that are not available" do
    HammerCLI::I18n.add_domain(domain1)
    HammerCLI::I18n.add_domain(domain2)
    HammerCLI::I18n.add_domain(unavailable_domain)
    HammerCLI::I18n.domains.must_equal [domain1, domain2]
  end


end

