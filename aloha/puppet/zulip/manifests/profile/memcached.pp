class aloha::profile::memcached {
  include aloha::profile::base
  include aloha::sasl_modules
  include aloha::systemd_daemon_reload

  case $::os['family'] {
    'Debian': {
      $memcached_packages = [ 'memcached', 'sasl2-bin' ]
      $memcached_user = 'memcache'
    }
    'RedHat': {
      $memcached_packages = [ 'memcached', 'cyrus-sasl' ]
      $memcached_user = 'memcached'
    }
    default: {
      fail('osfamily not supported')
    }
  }
  package { $memcached_packages: ensure => installed }

  $memcached_memory = alohaconf('memcached', 'memory', $aloha::common::total_memory_mb / 8)
  file { '/etc/sasl2':
    ensure => directory,
  }
  file { '/etc/sasl2/memcached-aloha-password':
    # We cache the password in this file so we can check whether it
    # changed and avoid running saslpasswd2 if it didn't.
    require => File['/etc/sasl2'],
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => alohasecret('secrets', 'memcached_password', ''),
    notify  => Exec[generate_memcached_sasldb2],
  }
  file { '/var/lib/aloha/memcached-sasldb2.stamp':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => '1',
    notify  => Exec[generate_memcached_sasldb2],
  }
  exec { 'generate_memcached_sasldb2':
    require     => [
      Package[$memcached_packages],
      Package[$aloha::sasl_modules::sasl_module_packages],
    ],
    refreshonly => true,
    # Use localhost for the currently recommended MEMCACHED_USERNAME =
    # "aloha@localhost" and the hostname for compatibility with
    # MEMCACHED_USERNAME = "aloha".
    command     => "bash -euc '
rm -f /etc/sasl2/memcached-sasldb2
saslpasswd2 -p -f /etc/sasl2/memcached-sasldb2 \
    -a memcached -u localhost aloha < /etc/sasl2/memcached-aloha-password
saslpasswd2 -p -f /etc/sasl2/memcached-sasldb2 \
    -a memcached -u \"\$HOSTNAME\" aloha < /etc/sasl2/memcached-aloha-password
'",
  }
  file { '/etc/sasl2/memcached-sasldb2':
    require => Exec[generate_memcached_sasldb2],
    owner   => $memcached_user,
    group   => $memcached_user,
    mode    => '0600',
  }
  file { '/etc/sasl2/memcached.conf':
    require => File['/etc/sasl2'],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/sasl2/memcached.conf',
    notify  => Service[memcached],
  }
  file { '/etc/memcached.conf':
    ensure  => file,
    require => [
      Package[$memcached_packages],
      Package[$aloha::sasl_modules::sasl_module_packages]
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha/memcached.conf.template.erb'),
  }
  file { '/run/memcached':
    ensure  => directory,
    owner   => 'memcache',
    group   => 'memcache',
    mode    => '0755',
    require => Package[$memcached_packages],
  }
  service { 'memcached':
    ensure    => running,
    subscribe => File['/etc/memcached.conf'],
    require   => [File['/run/memcached'], Class['aloha::systemd_daemon_reload']],
  }
}
