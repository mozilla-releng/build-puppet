# == Class: telegraf::config
#
# Templated generation of telegraf.conf
#
class telegraf::config inherits telegraf {

  file {
    $::telegraf::config_file:
      ensure  => file,
      content => template('telegraf/telegraf.conf.erb'),
      owner   => $::telegraf::config_file_owner,
      group   => $::telegraf::config_file_group,
      mode    => '0640',
      notify  => Class['::telegraf::service'],
      require => Class['::telegraf::install'],
    ;
    $::telegraf::config_folder:
      ensure  => directory,
      owner   => $::telegraf::config_file_owner,
      group   => $::telegraf::config_file_group,
      mode    => '0770',
      purge   => $::telegraf::purge_config_fragments,
      recurse => true,
      notify  => Class['::telegraf::service'],
      require => Class['::telegraf::install'],
    ;
  }

}
