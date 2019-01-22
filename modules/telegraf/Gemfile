source 'https://rubygems.org'

gem 'rake'
gem 'safe_yaml', '~> 1.0.4'
gem 'metadata-json-lint'

group :test do
  gem "beaker"
  gem "beaker-rspec"
  gem 'beaker-puppet_install_helper'
  gem "puppet", ENV['PUPPET_VERSION'] || ">  3.7.0"
  gem "puppetlabs_spec_helper"
  gem "rspec"
  gem "rspec-puppet"
end
