require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*test.rb']
  t.verbose = !!ENV['DEBUG']
end

task :default => :test
