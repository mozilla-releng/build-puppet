# == Class: telegraf::install
#
# Conditionally handle InfluxData's official repos and install the necessary
# Telegraf package.
#
class telegraf::install {

  $_operatingsystem = downcase($::operatingsystem)

  if $::telegraf::manage_repo {
    case $::osfamily {
      'RedHat': {
        yumrepo { 'influxdata':
          name     => 'influxdata',
          descr    => "InfluxData Repository - ${::operatingsystem} \$releasever",
          enabled  => 1,
          baseurl  => "https://repos.influxdata.com/rhel/\$releasever/\$basearch/${::telegraf::repo_type}",
          gpgkey   => 'https://repos.influxdata.com/influxdb.key',
          gpgcheck => 1,
        }
        Yumrepo['influxdata'] -> Package[$::telegraf::package_name]
      }
      'windows': {
        # repo is not applicable to windows
      }
      default: {
        # repo is only being used for RedHat/CentOS
      }
    }
  }

  if $::osfamily == 'windows' {
    # required to install telegraf on windows
    require chocolatey

    # package install
    package { $::telegraf::package_name:
      ensure          => $::telegraf::ensure,
      provider        => chocolatey,
      source          => $::telegraf::windows_package_url,
      install_options => $::telegraf::install_options,
    }
  } elsif $::osfamily != 'RedHat' {
    require packages::telegraf
    require users::telegraf
  } else {
    ensure_packages([$::telegraf::package_name])
  }

}
