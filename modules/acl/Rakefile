require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
require 'beaker/tasks/test' unless RUBY_PLATFORM =~ /win32/

task :default => [:test]

desc 'Run RSpec'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/{unit}/**/*.rb'
#  t.rspec_opts = ['--color']
end

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

desc 'Run Beaker PE Tests'
task :beaker_pe, [:hosts, :tests] do |t, args|
  args.with_defaults({:type => 'pe'})
  system(build_command(args))
end

desc 'Run Beaker Git Tests'
task :beaker_git, [:hosts, :tests] do |t, args|
  args.with_defaults({:type => 'git'})
  system(build_command(args))
end

def build_command(args)
  cmd_parts = []
  cmd_parts << "beaker"
  cmd_parts << "--options-file ./acceptance/.beaker-#{args[:type]}.cfg"
  cmd_parts << "--hosts #{args[:hosts]}" if !args.hosts.empty?
  cmd_parts << "--tests #{args.tests}" if !args.tests.empty?
  cmd_parts.flatten.join(" ")
end
