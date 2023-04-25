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
          task :find_new do
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

        namespace :tx do
          desc 'Pull translaions from transifex'
          task :pull do
            raise 'Command tx not found. Make sure you have transifex-client installed and configured.' unless system("command -v tx >/dev/null 2>&1")

            sh "tx pull -f"
            edit_files = Dir.glob(File.expand_path("#{@domain.locale_dir}/**/*.edit.po", __dir__))
            edit_files.each do |edit_file|
              `sed -i 's/^\\("Project-Id-Version: \\).*$/\\1#{@domain.domain_name} #{@version}\\\\n"/' #{edit_file};`
            end
          end

          desc 'Merge .edit.po into .po'
          task :update_po do
            edit_files = Dir.glob(File.expand_path("#{@domain.locale_dir}/**/*.edit.po", __dir__))
            edit_files.each do |edit_file|
              po_file = edit_file.gsub('.edit.po', '.po')
              `msgcat --use-first --no-location #{edit_file} #{po_file} > #{po_file}`
            end
          end

          desc 'Generate MO files from PO files'
          task :all_mo do
            po_files = Dir.glob(File.expand_path("#{@domain.locale_dir}/**/#{@domain.domain_name}.po", __dir__))
            po_files.each do |po_file|
              dir = File.dirname(po_file) + '/LC_MESSAGES'
              FileUtils.mkdir_p(dir)
              `msgfmt -o #{dir}/#{@domain.domain_name}.mo #{po_file}`
            end
          end

          desc 'Download and merge translations from Transifex'
          task :update do
            Rake::Task['gettext:find_new'].invoke
            Rake::Task['gettext:find'].invoke
            Rake::Task['tx:pull'].invoke
            Rake::Task['tx:update_po'].invoke
            Rake::Task['tx:all_mo'].invoke
            locale_dir = File.expand_path(@domain.locale_dir, __dir__)
            `git add #{locale_dir}`
            `git commit -m "i18n - extracting new, pulling from tx"`
            puts 'Changes commited!'
          end

          desc 'Check for malformed strings'
          task :check do
            raise 'Command pofilter not found. Make sure you have translate-toolkit installed.' unless system("command -v pofilter >/dev/null 2>&1")

            po_files = Dir.glob(File.expand_path("#{@domain.locale_dir}/**/#{@domain.domain_name}.po", __dir__))
            po_files.each do |po_file|
              pox_file = po_file.gsub('.po', '.pox')
              `msgfmt -c #{po_file}`
              `pofilter --nofuzzy -t variables -t blank -t urls -t emails -t long -t newlines -t endwhitespace -t endpunc \
                -t puncspacing -t options -t printf -t validchars --gnome #{po_file} > #{pox_file};`
              `cat #{pox_file}`
              `! grep -q msgid #{pox_file}`
            end
          end

          desc 'Clean everything, removes *.edit.po, *.po.timestamp and *.pox files'
          task :clean do
            edit_files = Dir.glob(File.expand_path("#{@domain.locale_dir}/**/*.edit.po", __dir__))
            timestamp_files = Dir.glob(File.expand_path("#{@domain.locale_dir}/**/*.po.time_stamp", __dir__))
            pox_files = Dir.glob(File.expand_path("#{@domain.locale_dir}/**/*.pox", __dir__))
            FileUtils.rm_f(edit_files + timestamp_files + pox_files)
          end
        end
      end

      def self.define(domain, version)
        new(domain, version).define
      end
    end
  end
end
