# @summary Included only by classes that can be deployed.
#
# This class should only be included by classes that are intended to
# be able to be deployed on their own host.
class aloha::profile::base {
  include aloha::common
  case $::os['family'] {
    'Debian': {
      include aloha::apt_repository
    }
    'RedHat': {
      include aloha::yum_repository
    }
    default: {
      fail('osfamily not supported')
    }
  }
  case $::os['family'] {
    'Debian': {
      $base_packages = [
        # Basics
        'python3',
        'python3-yaml',
        'puppet',
        'git',
        'curl',
        'jq',
        'procps',
        # Used to read /etc/aloha/aloha.conf for `alohaconf` Puppet function
        'crudini',
        # Accurate time is essential
        'chrony',
        # Used for tools like sponge
        'moreutils',
        # Nagios monitoring plugins
        $aloha::common::nagios_plugins,
        # Required for using HTTPS in apt repositories.
        'apt-transport-https',
        # Needed for the cron jobs installed by Puppet
        'cron',
      ]
    }
    'RedHat': {
      $base_packages = [
        'python3',
        'python3-pyyaml',
        'puppet',
        'git',
        'curl',
        'jq',
        'crudini',
        'chrony',
        'moreutils',
        'nmap-ncat',
        'nagios-plugins',  # there is no dummy package on CentOS 7
        'cronie',
      ]
    }
    default: {
      fail('osfamily not supported')
    }
  }
  package { 'ntp': ensure => purged, before => Package['chrony'] }
  service { 'chrony': require => Package['chrony'] }
  package { $base_packages: ensure => installed }

  group { 'aloha':
    ensure => present,
  }

  user { 'aloha':
    ensure     => present,
    require    => Group['aloha'],
    gid        => 'aloha',
    shell      => '/bin/bash',
    home       => '/home/aloha',
    managehome => true,
  }

  file { '/etc/aloha':
    ensure => directory,
    mode   => '0644',
    owner  => 'aloha',
    group  => 'aloha',
    links  => follow,
  }
  file { ['/etc/aloha/aloha.conf', '/etc/aloha/settings.py']:
    ensure  => file,
    require => File['/etc/aloha'],
    mode    => '0644',
    owner   => 'aloha',
    group   => 'aloha',
  }
  file { '/etc/aloha/aloha-secrets.conf':
    ensure  => file,
    require => File['/etc/aloha'],
    mode    => '0640',
    owner   => 'aloha',
    group   => 'aloha',
  }

  file { '/etc/security/limits.conf':
    ensure => file,
    mode   => '0640',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/aloha/limits.conf',
  }

  # This directory is written to by cron jobs for reading by Nagios
  file { '/var/lib/nagios_state/':
    ensure => directory,
    group  => 'aloha',
    mode   => '0774',
  }

  file { '/var/log/aloha':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
    mode   => '0640',
  }

  file { "${aloha::common::nagios_plugins_dir}/aloha_base":
    require => Package[$aloha::common::nagios_plugins],
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/aloha/nagios_plugins/aloha_base',
  }
}
