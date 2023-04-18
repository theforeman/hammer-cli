require 'rake'
require 'fileutils'
require_relative '../task_helper'

module HammerCLI
  module I18n
    class FindTask
      include Rake::DSL

      def initialize(domain, version)
        @domain = domain
        @version = version
      end

      def define
        namespace :gettext do
          task :setup do
            require 'gettext/tools/task'

            GetText::Tools::Task.define do |task|
              task.package_name = @domain.domain_name
              task.package_version = @version.to_s
              task.domain = @domain.domain_name
              task.mo_base_directory = @domain.locale_dir
              task.po_base_directory = @domain.locale_dir
              task.files = @domain.translated_files
              task.msgmerge_options='--no-fuzzy-matching'
            end
          end

          desc "Update pot file"
          task :find => [:setup] do
            Rake::Task["gettext:po:update"].invoke
          end

          desc 'Check languages with 50% or more coverage and create needed files'
          task :find_new => [:setup] do
            client = HammerCLI::TaskHelper::I18n::TxApiClient.new(domain: @domain)
            stats = client.language_stats_collection
            lang_percentages = stats['data'].each_with_object({}) do |lang, res|
              res[lang['id'].split(':').last] = (lang['attributes']['translated_strings'] * 100.0 / lang['attributes']['total_strings']).round
            end
            lang_percentages.select { |_, v| v >= 50 }.each_key do |lang|
              lang_dir = File.expand_path("#{@domain.locale_dir}/#{lang}")
              FileUtils.mkpath(lang_dir)
              FileUtils.cp(File.expand_path("#{@domain.locale_dir}/#{@domain.domain_name}.pot", __dir__), "#{lang_dir}/#{@domain.domain_name}.po")
            end
          end
        end
      end

      def self.define(domain, version)
        new(domain, version).define
      end
    end
  end
end
