require 'rake'

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
        end
      end

      def self.define(domain, version)
        new(domain, version).define
      end
    end
  end
end
