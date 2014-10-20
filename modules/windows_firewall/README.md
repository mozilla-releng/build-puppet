#windows_firewall
[![Build
Status](https://secure.travis-ci.org/liamjbennett/puppet-windows_firewall.png)](http://travis-ci.org/liamjbennett/puppet-windows_firewall)
[![Dependency
Status](https://gemnasium.com/liamjbennett/puppet-windows_firewall.png)](http://gemnasium.com/liamjbennett/puppet-windows_firewall)

####Table of Contents

1. [Overview - What is the windows_firewall module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with windows_firewall](#setup)
    * [Beginning with windows_firewall - Installation](#beginning-with-windows_firewall)
    * [Configuring an exception - Basic options for for getting started](#configure-an-exception)
4. [Usage - The classes, defined types, and their parameters available for configuration](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: windows_firewall](#class-windows_firewall)
        * [Defined Type: windows_firewall::exception](#defined-type-exception)
5. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
    * [Classes and Defined Types](#classes-and-defined-types)
    * [Templates](#templates)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

##Overview
Puppet module to manage the Microsoft Windows Firewall

##Module Description

##Setup

###What windows_firewall affects:

* windows firewall service and corrisponding Windows Registry keys
* windows registry keys and values for any defined exception rules

###Setup Requirements

For this module to run correctly, you must have [pluginsync enabled](http://docs.puppetlabs.com/guides/plugins_in_modules.html#enabling-pluginsync). 

This setting will ensure the types and providers are synchronized and available on the agent before the configuration run takes place. This is the default behavior of the puppet agent on Microsoft Windows platforms. 

###Beginning with windows_firewall
To begin using Windows_firewall, you must download the module to your puppet master. This module is intended for installation on a *nix master for use with a Windows agent.


The windows_firewall resource allows you to manage the firewall service itself. 

	class { 'windows_firewall': ensure => 'stopped' }

Once the windows firewall is managed you may then want to start managing the rules and exceptions within it. 

    windows_firewall::exception { 'WINRM':
      ensure       => present,
      direction    => 'in',
      action       => 'Allow',
      enabled      => 'yes',
      protocol     => 'TCP',
      port         => '5985',
      display_name => 'Windows Remote Management HTTP-In',
      description  => 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]',
    }

##Usage

###Class: `windows_firewall`

The `windows_firewall` resource allows you to use Puppet to manage the firewall service itself.

    class { 'windows_firewall':
        ensure => 'stopped'
    }

In the above example the windows firewall is made sure to be running during each puppet run.

#### Parameters in `windows_firewall`

#####`ensure`
Determines whether or not the service must be running and enabled. If not included, the module will assume that the windows firewall service should be running and enabled. Valid values are 'running' and 'stopped'.

###Defined Type: `windows_firewall::exception`

The `windows_firewall::exception` defined type allows the management of indivdual rules in the windows firewall.

You can either define an exception for a specific port:

    windows_firewall::exception { 'WINRM':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        protocol     => 'TCP',
        port         => '5985',
        display_name => 'Windows Remote Management HTTP-In',
        description  => 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]',
    }

Or you can define an exception for a specific program:

    windows_firewall::exception { 'myapp':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\\myapp.exe',
        display_name => 'My App',
        description  => 'Inbound rule for My App',
    }

#### Parameters in `windows_firewall::exception`

#####`ensure`
Determines whether or not the firewall exception is 'present' or 'absent'

#####`description`
A description of the exception to apply. 

#####`display_name`
Sets the Display Name of the exception rule. Defaults to the title of the resource.

#####`direction`
Sets the direction of the exception rule, either: 'in' or 'out'.

#####`action`
Sets the action type of the excepton, either: 'allow' or 'block'.

#####`enabled`
Determines whether the exception is enabled, either: 'yes' or 'no'. Defaults to 'yes'.

#####`protocol`
Sets the protocol to be included in the exception rule, either: 'TCP' or 'UDP'.

#####`local_port`
Defines the port to be included in the exception for port-based exception rules.

#####`program`
Defines the full path to the program to be included in the exception for program-based exception rules.

##Limitations

This module was developed for use on *nix puppet master with Windows puppet agents.

Please log tickets and issues at our [Module Issue Tracker](http://projects.puppetlabs.com/projects/modules).

##Development

### Running tests

This project contains tests for [rspec-puppet](http://rspec-puppet.com/) to verify functionality. For in-depth information please see their respective documentation.

Quickstart:

    gem install bundler
    bundle install
    bundle exec rake spec

##Copyright and License

Copyright (C) 2013 Liam Bennett - liamjbennett@gmail.com 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
