# == Class: vmwaretools::install::exec
#
# This class handles the VMware Tools compilation and uncompressing.
#
# == Actions:
#
# Uncompresses the VMware Tools tarball
# Installs VMware Tools, accepting all installer defaults
# Cleans up old tarballs
# Cleans up VMware Tools uncompressed files
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
class vmwaretools::install::exec {

  Exec {
    path        => ['/bin','/usr/bin'],
    refreshonly => true,
    timeout     => 0,
  }

  if $vmwaretools::archive_url != 'puppet' {
    exec { 'download_vmwaretools':
      command => "${vmwaretools::working_dir}/download.sh",
      require => File["${vmwaretools::working_dir}/download.sh"],
      notify  => Exec['uncompress_vmwaretools'],
    }

    Exec['uncompress_vmwaretools'] {
      require => Exec['download_vmwaretools'],
    }

  } else {
    Exec['uncompress_vmwaretools'] {
      require => File["${vmwaretools::working_dir}/VMwareTools-${vmwaretools::version}.tar.gz"],
    }
  }

  exec {
    'uncompress_vmwaretools':
      cwd     => $vmwaretools::working_dir,
      command => "tar -xf ${vmwaretools::working_dir}/VMwareTools-${vmwaretools::version}.tar.gz",
      notify  => Exec['install_vmwaretools'];
    'install_vmwaretools':
      command => "${vmwaretools::working_dir}/vmware-tools-distrib/vmware-install.pl -d",
      require => Exec['uncompress_vmwaretools'],
      notify  => Exec['clean_vmwaretools'];
    'clean_vmwaretools':
      command => "rm -rf ${vmwaretools::working_dir}/vmware-tools-distrib && find ${vmwaretools::working_dir}/*.tar.gz -not -name VMwareTools-${vmwaretools::version}.tar.gz -delete",
      require => Exec['install_vmwaretools'];
  }

  if $vmwaretools::keep_working_dir == false {
    Exec['clean_vmwaretools'] {
      notify => Exec['remove_vmwaretools_working_dir'],
    }

    exec { 'remove_vmwaretools_working_dir':
      command => "rm -rf ${vmwaretools::working_dir}",
      require => Exec['clean_vmwaretools'],
    }
  }
}
