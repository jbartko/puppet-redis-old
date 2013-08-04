# Class: redis::params
#
# This class configures parameters for the puppet-redis module.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class redis::params {

  case $::osfamily {
    'RedHat': {
      $package       = 'redis'
      $service       = 'redis'
      $bindir        = '/usr/local/bin'
      $conf_file     = '/etc/redis.conf'
      $conf_template = 'redis.rhel.conf.erb'
      $conf_pidfile  = '/var/run/redis/redis.pid'
      $logfile       = '/var/log/redis/redis.log'
      $init_template = 'redis.init.erb'
    }
    'Debian': {
      $package       = 'redis-server'
      $service       = 'redis-server'
      $bindir        = '/usr/local/bin'
      $conf_file     = '/etc/redis/redis.conf'
      $conf_template = 'redis.debian.conf.erb'
      $conf_pidfile  = '/var/run/redis.pid'
      $logfile       = '/var/log/redis/redis-server.log'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }

}
