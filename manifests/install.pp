# == Class ntp::install
#
# This class is called from ntp for install.
#
class ntp::install {

  package { $::ntp::package_name:
    ensure => present,
  }
}
