source "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place =~ /^(git:[^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

gem "puppet", '~> 3.4.0' #*location_for(ENV['PUPPET_LOCATION'] || '~> 3.4.0')
gem "facter", *location_for(ENV['FACTER_LOCATION'] || '~> 1.6')
gem "hiera", *location_for(ENV['HIERA_LOCATION'] || '~> 1.0')

beaker_version = ENV['BEAKER_VERSION']
group :development, :test do
  gem 'pry'
  gem 'rake'
  gem 'rspec', "~> 2.11.0"
  gem 'mocha', "~> 0.10.5"
  # beaker is not supported to be installed on windows
  if beaker_version
    gem 'beaker', *location_for(beaker_version)
  else
    gem 'beaker',                :require => false, :platforms => :ruby
  end
  gem 'puppetlabs_spec_helper'
end

# see http://projects.puppetlabs.com/issues/21698
platforms :mswin, :mingw do
  gem "ffi", "1.9.0", :require => false
  gem "sys-admin", "~> 1.5.6", :require => false
  gem "win32-api", "~> 1.4.8", :require => false
  gem "win32-dir", "~> 0.3.7", :require => false
  gem "win32-eventlog", "~> 0.5.3", :require => false
  gem "win32-process", "~> 0.6.5", :require => false
  gem "win32-security", "~> 0.1.4", :require => false
  gem "win32-service", "~> 0.7.2", :require => false
  gem "win32-taskscheduler", "~> 0.2.2", :require => false
  gem "win32console", "~> 1.3.2", :require => false
  gem "windows-api", "~> 0.4.2", :require => false
  gem "windows-pr", "~> 1.2.1", :require => false
  gem "minitar", "~> 0.5.4", :require => false
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
