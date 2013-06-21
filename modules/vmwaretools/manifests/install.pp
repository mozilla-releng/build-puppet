# == Class: vmwaretools::install
#
# Top-level vmwaretools installation class
#
# == Actions:
#
# Includes the archive/package/exec installation submodules
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
class vmwaretools::install {

  if $vmwaretools::params::deploy_files == true {
    include vmwaretools::install::archive
    include vmwaretools::install::package
    include vmwaretools::install::exec

    Class['vmwaretools::install::package'] ->
    Class['vmwaretools::install::archive'] ->
    Class['vmwaretools::install::exec']
  }
}
