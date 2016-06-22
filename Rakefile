require 'rake/testtask'
require 'bundler/gem_tasks'
require 'ci/reporter/rake/minitest'

PREFIX = ENV['PREFIX'] || '/usr/local'
DATAROOTDIR = ENV['DATAROOTDIR'] || "#{PREFIX}/share"
MANDIR = ENV['MANDIR'] || "#{DATAROOTDIR}/man"


Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.verbose = true
end

file "man/hammer.1.gz" => "man/hammer.1.asciidoc" do |t|
  sh "which a2x" do |ok, res|
    if !ok
      puts "asciidoc is not installed... leaving"
      exit
    end
  end

  sh "a2x -d manpage -f manpage -D man/ #{t.prerequisites[0]}"
  sh "gzip -f9 man/hammer.1"
end

task :build => ["man/hammer.1.gz"]

task :install => :build do |t|
  begin
    Rake::Task["man:install"].invoke
  rescue SystemCallError => e
    warn "Unable to install man page. #{e}. Skipping. You can try 'sudo rake man:install' to proceed."
  end
end

namespace :man do
  desc 'Install man page'
  task :install do |t|
    mkdir_p "#{MANDIR}/man1"
    cp "man/hammer.1.gz", "#{MANDIR}/man1/"
  end
end

namespace :gettext do

  task :setup do
    require "hammer_cli/version"
    require "hammer_cli/i18n"
    require 'gettext/tools/task'

    domain = HammerCLI::I18n::LocaleDomain.new
    GetText::Tools::Task.define do |task|
      task.package_name = domain.domain_name
      task.package_version = HammerCLI.version.to_s
      task.domain = domain.domain_name
      task.mo_base_directory = domain.locale_dir
      task.po_base_directory = domain.locale_dir
      task.files = domain.translated_files
    end
  end

  desc "Update pot file"
  task :find => [:setup] do
    Rake::Task["gettext:po:update"].invoke
  end

end

namespace :pkg do
  desc 'Generate package source gem'
  task :generate_source => :build
end
