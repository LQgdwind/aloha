class aloha_ops::profile::prod_app_frontend {
  include aloha_ops::profile::base
  include aloha_ops::app_frontend

  file { '/etc/nginx/sites-available/aloha':
    ensure  => file,
    require => Package['nginx-full'],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha_ops/nginx/sites-available/aloha',
    notify  => Service['nginx'],
  }

  file { '/etc/nginx/sites-enabled/aloha':
    ensure  => link,
    require => Package['nginx-full'],
    target  => '/etc/nginx/sites-available/aloha',
    notify  => Service['nginx'],
  }

  file { '/usr/lib/nagios/plugins/aloha_zephyr_mirror':
    require => Package[$aloha::common::nagios_plugins],
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/aloha_ops/nagios_plugins/aloha_zephyr_mirror',
  }

  # Prod has our Apple Push Notifications Service private key at
  # /etc/ssl/django-private/apns-dist.pem
}
