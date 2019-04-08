# == Class: telegraf::service
#
# Optionally manage the Telegraf service.
#
class telegraf::service {

  case $::operatingsystem {
    'Ubuntu' : {
      $service_provider = 'systemd'
    }
    'Darwin' : {
      $service_name = 'com.influxdb.telegraf'
    }
    default : {
      $service_provider = undef
    }
  }

  if $::telegraf::manage_service {
    service { 'telegraf':
      name      => $service_name,
      ensure    => $telegraf::service_ensure,
      hasstatus => $telegraf::service_hasstatus,
      enable    => $telegraf::service_enable,
      restart   => $telegraf::service_restart,
      require   => Class['::telegraf::config'],
      provider  => $service_provider,
    }
  }
}
