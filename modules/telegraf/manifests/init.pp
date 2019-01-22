# == Class: telegraf
#
# A Puppet module for installing InfluxData's Telegraf
#
# === Parameters
#
# [*package_name*]
#   String. Package name.
#
# [*ensure*]
#   String. State of the telegraf package. You can also specify a
#   particular version to install.
#
# [*config_file*]
#   String. Path to the configuration file.
#
# [*logfile*]
#   String. Path to the log file.
#
# [*config_file_owner*]
#   String. User to own the telegraf config file.
#
# [*config_file_group*]
#   String. Group to own the telegraf config file.
#
# [*config_folder*]
#   String. Path of additional telegraf config files.
#
# [*hostname*]
#   String. Override default hostname used to identify this agent.
#
# [*omit_hostname*]
#   Boolean. Do not set the "host" tag in the telegraf agent.
#
# [*interval*]
#   String. Default data collection interval for all inputs.
#
# [*round_interval*]
#   Boolean. Rounds collection interval to 'interval'
#
# [*metric_batch_size*] Integer. The maximum batch size to allow to
#   accumulate before sending a flush to the configured outputs
#
# [*metric_buffer_limit*] Integer.  The absolute maximum number of
#   metrics that will accumulate before metrics are dropped.
#
# [*collection_jitter*]
#   String.  Sleep for a random time within jitter before collecting.
#
# [*flush_interval*]
#   String. Default flushing interval for all outputs.
#
# [*flush_jitter*]
#   String.  Jitter the flush interval by an amount.
#
# [*debug*]
#   Boolean. Run telegraf in debug mode.
#
# [*quiet*]
#   Boolean.  Run telegraf in quiet mode.
#
# [*outputs*]
#   Hash. Specify output plugins and their options.
#
# [*inputs*]
#   Hash.  Specify input plugins and their options.
#
# [*global_tags*]
#   Hash.  Global tags as a key-value pair.
#
# [*manage_service*]
#   Boolean.  Whether to manage the telegraf service or not.
#
# [*manage_repo*]
#   Boolean.  Whether or not to manage InfluxData's repo.
#
# [*install_options*]
#   String or Array. Additional options to pass when installing package
#
# [*purge_config_fragments*]
#   Boolean. Whether unmanaged configuration fragments should be removed.
#
# [*repo_type*]
#   String.  Which repo (stable, unstable, nightly) to use
#
# [*windows_package_url*]
#   String.  URL for windows telegraf chocolatey repo
#
class telegraf (
  $package_name           = $telegraf::params::package_name,
  $ensure                 = $telegraf::params::ensure,
  $config_file            = $telegraf::params::config_file,
  $config_file_owner      = $telegraf::params::config_file_owner,
  $config_file_group      = $telegraf::params::config_file_group,
  $config_folder          = $telegraf::params::config_folder,
  $hostname               = $telegraf::params::hostname,
  $omit_hostname          = $telegraf::params::omit_hostname,
  $interval               = $telegraf::params::interval,
  $round_interval         = $telegraf::params::round_interval,
  $metric_batch_size      = $telegraf::params::metric_batch_size,
  $metric_buffer_limit    = $telegraf::params::metric_buffer_limit,
  $collection_jitter      = $telegraf::params::collection_jitter,
  $flush_interval         = $telegraf::params::flush_interval,
  $flush_jitter           = $telegraf::params::flush_jitter,
  $logfile                = $telegraf::params::logfile,
  $debug                  = $telegraf::params::debug,
  $quiet                  = $telegraf::params::quiet,
  $inputs                 = $telegraf::params::inputs,
  $outputs                = $telegraf::params::outputs,
  $global_tags            = $telegraf::params::global_tags,
  $manage_service         = $telegraf::params::manage_service,
  $manage_repo            = $telegraf::params::manage_repo,
  $purge_config_fragments = $telegraf::params::purge_config_fragments,
  $repo_type              = $telegraf::params::repo_type,
  $windows_package_url    = $telegraf::params::windows_package_url,
  $service_enable         = $telegraf::params::service_enable,
  $service_ensure         = $telegraf::params::service_ensure,
  $install_options        = $telegraf::params::install_options,
) inherits ::telegraf::params
{

  $service_hasstatus = $telegraf::params::service_hasstatus
  $service_restart   = $telegraf::params::service_restart

  validate_string($package_name)
  validate_string($ensure)
  validate_string($config_file)
  validate_string($logfile)
  validate_string($config_file_owner)
  validate_string($config_file_group)
  validate_absolute_path($config_folder)
  validate_string($hostname)
  validate_bool($omit_hostname)
  validate_string($interval)
  validate_bool($round_interval)
  validate_integer($metric_batch_size)
  validate_integer($metric_buffer_limit)
  validate_string($collection_jitter)
  validate_string($flush_interval)
  validate_string($flush_jitter)
  validate_bool($debug)
  validate_bool($quiet)
  validate_hash($inputs)
  validate_hash($outputs)
  validate_hash($global_tags)
  validate_bool($manage_service)
  validate_bool($manage_repo)
  validate_bool($purge_config_fragments)
  validate_string($repo_type)
  validate_string($windows_package_url)
  validate_bool($service_hasstatus)
  validate_string($service_restart)
  validate_bool($service_enable)
  validate_string($service_ensure)

  # currently the only way how to obtain merged hashes
  # from multiple files (`:merge_behavior: deeper` needs to be
  # set in your `hiera.yaml`)
  $_outputs = hiera_hash('telegraf::outputs', $outputs)
  $_inputs = hiera_hash('telegraf::inputs', $inputs)

  contain ::telegraf::install
  contain ::telegraf::config
  contain ::telegraf::service

  Class['::telegraf::install']
  -> Class['::telegraf::config']
  -> Class['::telegraf::service']
}
