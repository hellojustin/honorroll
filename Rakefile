require 'rake/testtask'
require 'rocco/tasks'

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
end

Rocco::make 'docs/', 'lib/**/*.rb'

desc 'Generates Rocco documents in the docs/ directory'
task :docs => :rocco

task default: 'test'
