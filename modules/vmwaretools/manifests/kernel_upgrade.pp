# == Class: vmwaretools::kernel_upgrade
#
# This class handles re-compiling VMware Tools after a kernel upgrade.
#
# == Actions:
#
# Executes '/usr/bin/vmware-config-tools.pl -d'
#
# === Authors:
#
# Craig Watson <craig@cwatson.org>
#
# === Copyright:
#
# Copyright (C) 2013 Craig Watson
# Published under the GNU General Public License v3
#
class vmwaretools::kernel_upgrade {

  if $vmwaretools::params::deploy_files {
    Exec['vmware_config_tools'] {
      require => Exec['clean_vmwaretools'],
    }
  }

  exec { 'vmware_config_tools':
    command => '/usr/bin/vmware-config-tools.pl -d',
    creates => "/lib/modules/${::kernelrelease}/misc/vmci.ko",
  }

}
