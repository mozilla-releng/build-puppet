# == Define: telegraf::output
#
# A Puppet wrapper for discrete Telegraf output files
#
# === Parameters
#
# [*options*]
#   Hash. Plugin options for use the the output template.
#
# [*sections*]
#   Hash. Some outputs take multiple sections.
#
define telegraf::output (
  $plugin_type = $name,
  $options     = undef,
  $suboptions  = undef,
  $sections    = undef,
) {
  include telegraf

  if $options {
    validate_hash($options)
  }

  if $sections {
    validate_hash($sections)
  }

  Class['::telegraf::config']
  -> file { "${telegraf::config_folder}/output-${name}.conf":
    content => template('telegraf/output.conf.erb'),
  }
  ~> Class['::telegraf::service']
}
