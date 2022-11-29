class aloha_ops::app_frontend {
  include aloha::app_frontend_base
  include aloha::profile::memcached
  include aloha::profile::rabbitmq
  include aloha::postfix_localmail
  include aloha::static_asset_compiler
  include aloha_ops::app_frontend_monitoring
  $app_packages = [# Needed for the ssh tunnel to the redis server
    'autossh',
  ]
  package { $app_packages: ensure => installed }
  $redis_hostname = alohaconf('redis', 'hostname', undef)

  aloha_ops::firewall_allow{ 'smtp': }
  aloha_ops::firewall_allow{ 'http': }
  aloha_ops::firewall_allow{ 'https': }

  file { '/etc/logrotate.d/aloha':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/logrotate/aloha',
  }

  file { "${aloha::common::supervisor_conf_dir}/redis_tunnel.conf":
    ensure  => file,
    require => Package['supervisor', 'autossh'],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha_ops/supervisor/conf.d/redis_tunnel.conf.template.erb'),
    notify  => Service['supervisor'],
  }
  # Need redis_password in its own file for Nagios
  file { '/var/lib/nagios/redis_password':
    ensure  => file,
    mode    => '0600',
    owner   => 'nagios',
    group   => 'nagios',
    content => alohasecret('secrets', 'redis_password', ''),
  }

  # Each server does its own fetching of contributor data, since
  # we don't have a way to synchronize that among several servers.
  file { '/etc/cron.d/fetch-contributor-data':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/cron.d/fetch-contributor-data',
  }
}
