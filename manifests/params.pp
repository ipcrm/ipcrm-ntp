# == Class ntp::params
#
# This class is meant to be called from ntp.
# It sets variables according to platform.
#
class ntp::params {
  $servers = [
    '0.us.pool.ntp.org',
    '1.us.pool.ntp.org',
    '2.us.pool.ntp.org',
    '3.us.pool.ntp.org',
  ]

  case $::osfamily {
    'RedHat': {
      $package_name = 'ntp'
      $service_name = 'ntpd'
      $config_file  = '/etc/ntp.conf'
    }
    'Debian': {
      $package_name = 'ntp'
      $service_name = 'ntp'
      $config_file  = '/etc/ntp.conf'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
