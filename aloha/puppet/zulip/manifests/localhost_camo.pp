class aloha::localhost_camo {
  class { 'aloha::camo':
    listen_address => '127.0.0.1',
  }

  # Install nginx configuration to run camo locally
  file { '/etc/nginx/aloha-include/app.d/camo.conf':
    ensure  => file,
    require => Package['nginx-full'],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['nginx'],
    source  => 'puppet:///modules/aloha/nginx/aloha-include-app.d/camo.conf',
  }
}
