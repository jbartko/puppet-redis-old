# == Class: redis
#
# Install and configure a Redis server
#
# === Parameters
#
# All the redis.conf parameters can be passed to the class.
# Check the README.md file
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# === Examples
#
#  class { redis:
#    $conf_port => '6380',
#    $conf_bind => '0.0.0.0',
#  }
#
# === Authors
#
# Felipe Salum <fsalum@gmail.com>
#
# === Copyright
#
# Copyright 2013 Felipe Salum, unless otherwise noted.
#
class redis (
  $bindir                           = $redis::params::bindir,
  $conf_activerehashing             = 'yes',
  $conf_appendfilename              = undef,
  $conf_appendfsync                 = 'everysec',
  $conf_appendonly                  = 'no',
  $conf_auto_aof_rewrite_min_size   = '64mb',
  $conf_auto_aof_rewrite_percentage = '100',
  $conf_bind                        = '127.0.0.1',
  $conf_daemonize                   = 'yes',
  $conf_databases                   = '16',
  $conf_dbfilename                  = 'dump.rdb',
  $conf_dir                         = '/var/lib/redis/',
  $conf_file                        = $redis::params::conf_file,
  $conf_hash_max_zipmap_entries     = '512',
  $conf_hash_max_zipmap_value       = '64',
  $conf_include                     = undef,
  $conf_list_max_ziplist_entries    = '512',
  $conf_list_max_ziplist_value      = '64',
  $conf_logfile                     = undef,
  $conf_loglevel                    = 'notice',
  $conf_masterauth                  = undef,
  $conf_maxclients                  = undef,
  $conf_maxmemory_policy            = undef,
  $conf_maxmemory_samples           = undef,
  $conf_maxmemory                   = undef,
  $conf_no_appendfsync_on_rewrite   = 'no',
  $conf_pidfile                     = $redis::params::conf_pidfile,
  $conf_port                        = '6379',
  $conf_rdbcompression              = 'yes',
  $conf_repl_ping_slave_period      = '10',
  $conf_repl_timeout                = '60',
  $conf_requirepass                 = undef,
  $conf_save                        = undef,
  $conf_set_max_intset_entries      = '512',
  $conf_slaveof                     = undef,
  $conf_slave_server_stale_data     = 'yes',
  $conf_slowlog_log_slower_than     = '10000',
  $conf_slowlog_max_len             = '128',
  $conf_syslog_enabled              = undef,
  $conf_syslog_facility             = undef,
  $conf_syslog_ident                = undef,
  $conf_template                    = $redis::params::conf_template,
  $conf_timeout                     = '0',
  $conf_vm_enabled                  = 'no',
  $conf_vm_max_memory               = '0',
  $conf_vm_max_threads              = '4',
  $conf_vm_pages                    = '134217728',
  $conf_vm_page_size                = '32',
  $conf_vm_swap_file                = '/tmp/redis.swap',
  $conf_zset_max_ziplist_entries    = '128',
  $conf_zset_max_ziplist_value      = '64',
  $package                          = $redis::params::package,
  $package_ensure                   = 'present',
  $service_enable                   = true,
  $service_ensure                   = 'running',
  $service                          = $redis::params::service,
) inherits redis::params {

#  include redis::params

#  $conf_template = $redis::params::conf_template

#  $conf_pidfile_real = $conf_pidfile ? {
#    undef => $::redis::params::pidfile,
#    default => $conf_pidfile,
#  }

  $conf_logfile_real = $conf_logfile ? {
    undef => $::redis::params::logfile,
    default => $conf_logfile,
  }

#  $bindir_real = $bindir ? {
#    undef => $::redis::params::bindir,
#    default => $bindir,
#  }

  package { $package:
    ensure => $package_ensure,
  }

  if $::redis::params::init_template != undef {
    file { '/etc/init.d/redis':
      ensure  => present,
      content => template("redis/${$::redis::params::init_template}"),
      mode    => '0755',
      require => Package[$package],
    }
  }

  service { $service:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$package],
  }

  file { $conf_file:
    content => template("redis/${conf_template}"),
    owner   => root,
    group   => root,
    mode    => '0644',
    notify  => Service[$service],
  }

  file { '/etc/logrotate.d/redis':
    path    => '/etc/logrotate.d/redis',
    content => template('redis/redis.logrotate.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  exec { $conf_dir:
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "mkdir -p ${conf_dir}",
    user    => root,
    group   => root,
    creates => $conf_dir,
    before  => Service[$service],
    require => Package[$package],
    notify  => Service[$service],
  }

  $log_dir = '/var/log/redis'
  $run_dir = '/var/run/redis'
  file { [
          $conf_dir,
          $log_dir,
          $run_dir,
          ]:
    ensure  => directory,
    owner   => redis,
    group   => redis,
    before  => Service[$service],
    require => Exec[$conf_dir],
  }

}
