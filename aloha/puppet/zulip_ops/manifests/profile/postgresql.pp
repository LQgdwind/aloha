class aloha_ops::profile::postgresql {
  include aloha_ops::profile::base
  include aloha::profile::postgresql
  include aloha_ops::teleport::db

  $common_packages = ['xfsprogs']
  package { $common_packages: ensure => installed }

  aloha_ops::firewall_allow{ 'postgresql': }

  file { '/etc/sysctl.d/40-postgresql.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/postgresql/40-postgresql.conf',
  }
  exec { 'sysctl_p':
    command     => '/sbin/sysctl -p /etc/sysctl.d/40-postgresql.conf',
    subscribe   => File['/etc/sysctl.d/40-postgresql.conf'],
    refreshonly => true,
  }

  file { '/root/setup_disks.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0744',
    source => 'puppet:///modules/aloha_ops/postgresql/setup_disks.sh',
  }
  exec { 'setup_disks':
    command => '/root/setup_disks.sh',
    require => Package["postgresql-${aloha::postgresql_common::version}", 'xfsprogs'],
    unless  => 'test /var/lib/postgresql/ -ef /srv/postgresql/',
  }

  file { "${aloha::postgresql_base::postgresql_confdir}/pg_hba.conf":
    ensure  => file,
    require => Package["postgresql-${aloha::postgresql_common::version}"],
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0640',
    source  => 'puppet:///modules/aloha_ops/postgresql/pg_hba.conf',
  }
}
