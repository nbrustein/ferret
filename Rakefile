#!/usr/bin/env rake
require "bundler/gem_tasks"
 
require 'rake/testtask'
 
Rake::TestTask.new do |t|
  t.libs << 'lib/ferret'
  t.test_files = FileList['test/ferret/**/*_test.rb']
  t.verbose = true
end
 
task :default => :test