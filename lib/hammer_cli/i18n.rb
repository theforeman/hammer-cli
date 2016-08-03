require 'fast_gettext'
require 'locale'

module HammerCLI
  module I18n

    TEXT_DOMAIN = 'hammer-cli'

    # include this module to see translations highlighted
    module Debug
      DL = '>'
      DR = '<'

      # slightly modified copy of fast_gettext _ method
      def _(key)
        _wrap { FastGettext::Translation._(key) }
      end

      # slightly modified copy of fast_gettext n_ method
      def n_(*keys)
        _wrap { FastGettext::Translation.n_(*keys) }
      end

      # slightly modified copy of fast_gettext s_ method
      def s_(key, separator=nil, &block)
        _wrap { FastGettext::Translation.s_(key, separator, &block) }
      end

      # slightly modified copy of fast_gettext ns_ method
      def ns_(*args, &block)
        _wrap { FastGettext::Translation.ns_(*args, &block) }
      end

      def _wrap(&block)
        result = yield
        DL + result + DR unless result.nil?
      end
    end

    class AbstractLocaleDomain
      def available_locales
        Dir.glob(locale_dir+'/*').select { |f| File.directory? f }.map { |f| File.basename(f) }
      end

      def translated_files
        []
      end

      def type
        :mo
      end

      def available?
        Dir[File.join(locale_dir, '**', "#{domain_name}.#{type}")].any?
      end

      attr_reader :locale_dir, :domain_name
    end


    class LocaleDomain < AbstractLocaleDomain
      def translated_files
        Dir.glob(File.join(File.dirname(__FILE__), '../**/*.rb'))
      end

      def locale_dir
        File.join(File.dirname(__FILE__), '../../locale')
      end

      def domain_name
        'hammer-cli'
      end
    end

    class SystemLocaleDomain < LocaleDomain
      def locale_dir
        '/usr/share/locale'
      end
    end

    def self.locale
      lang_variant = Locale.current.to_simple.to_str
      lang = lang_variant.gsub(/_.*/, "")

      hammer_domain = HammerCLI::I18n::LocaleDomain.new
      if hammer_domain.available_locales.include? lang_variant
        lang_variant
      else
        lang
      end
    end

    def self.domains
      @domains ||= []
    end

    def self.add_domain(domain)
      if domain.available?
        domains << domain
        if base_repo_type == :merge
          translation_repository.add_repo(build_repository(domain))
        else
          translation_repository.chain << build_repository(domain)
        end
      end
    end

    def self.build_repository(domain)
      FastGettext::TranslationRepository.build(domain.domain_name, :path => domain.locale_dir, :type => domain.type, :report_warning => false)
    end

    def self.translation_repository
      FastGettext.translation_repositories[HammerCLI::I18n::TEXT_DOMAIN]
    end

    def self.base_repo_type
      (fast_gettext_version >= '1.2.0') ? :merge : :chain
    end

    def self.fast_gettext_version
      FastGettext::VERSION
    end

    def self.init(default_domains = [])
      Encoding.default_external='UTF-8' if defined? Encoding
      FastGettext.locale = locale
      FastGettext.text_domain = HammerCLI::I18n::TEXT_DOMAIN
      FastGettext.translation_repositories[HammerCLI::I18n::TEXT_DOMAIN] = FastGettext::TranslationRepository.build(HammerCLI::I18n::TEXT_DOMAIN, :type => base_repo_type, :chain => [])

      @domains = []
      default_domains.each do |domain|
        add_domain(domain)
      end
    end

    init
  end
end

include FastGettext::Translation


domain = [HammerCLI::I18n::LocaleDomain.new, HammerCLI::I18n::SystemLocaleDomain.new].find { |d| d.available? }
HammerCLI::I18n.add_domain(domain) if domain

