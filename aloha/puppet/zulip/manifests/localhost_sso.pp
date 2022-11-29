class aloha::localhost_sso {
  file { '/etc/nginx/aloha-include/app.d/external-sso.conf':
    ensure  => file,
    require => Package[$aloha::common::nginx],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['nginx'],
    source  => 'puppet:///modules/aloha/nginx/aloha-include-app.d/external-sso.conf',
  }
}
