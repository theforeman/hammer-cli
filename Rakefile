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
  t.warning = ENV.key?('RUBY_WARNINGS')
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

require "hammer_cli/version"
require "hammer_cli/i18n"
require "hammer_cli/i18n/find_task"
HammerCLI::I18n::FindTask.define(HammerCLI::I18n::LocaleDomain.new, HammerCLI.version)

namespace :pkg do
  desc 'Generate package source gem'
  task :generate_source => :build
end
