# == Class ntp::config
#
# This class is called from ntp for service config.
#
class ntp::config {
  file {$::ntp::config_file:
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('ntp/ntp.conf.erb')
  }
}
