require 'rake/testtask'
require 'bundler/gem_tasks'
require 'ci/reporter/rake/minitest'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.verbose = true
end


namespace :gettext do

  desc "Update pot file"
  task :find do
    require "hammer_cli/version"
    require "hammer_cli/i18n"
    require 'gettext/tools'

    domain = HammerCLI::I18n::LocaleDomain.new
    GetText.update_pofiles(domain.domain_name, domain.translated_files, "#{domain.domain_name} #{HammerCLI.version.to_s}", :po_root => domain.locale_dir)
  end

end
