
Local Port of the Datadog Agent Puppet config
=============================================

Cloned from https://github.com/DataDog/puppet-datadog-agent/commit/73fe2f4b75c60b7e059567a71018ec5fcecac55d

Local Changes 
=============

Added validate_integer, which wasn't in the releng puppet's stdlib

Ruby 1.8.7 has a different lambda function declaration style, so have reverted the more modern format.

Puppet 3.7 doesn't have the remote_file {} directive, so there is a copy of the yum repo's GPG key to copy down with file {}

