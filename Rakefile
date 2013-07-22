require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.verbose = true
end
