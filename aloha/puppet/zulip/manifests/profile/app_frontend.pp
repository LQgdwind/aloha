# Default configuration for a Aloha app frontend
class aloha::profile::app_frontend {
  include aloha::profile::base
  include aloha::app_frontend_base
  include aloha::app_frontend_once

  $nginx_http_only = alohaconf('application_server', 'http_only', false)
  if $nginx_http_only {
    $nginx_listen_port = alohaconf('application_server', 'nginx_listen_port', 80)
  } else {
    $nginx_listen_port = alohaconf('application_server', 'nginx_listen_port', 443)
  }
  $ssl_dir = $::os['family'] ? {
    'Debian' => '/etc/ssl',
    'RedHat' => '/etc/pki/tls',
  }
  file { '/etc/nginx/sites-available/aloha-enterprise':
    ensure  => file,
    require => Package[$aloha::common::nginx],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha/nginx/aloha-enterprise.template.erb'),
    notify  => Service['nginx'],
  }
  file { '/etc/logrotate.d/aloha':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/logrotate/aloha',
  }
  file { '/etc/nginx/sites-enabled/aloha-enterprise':
    ensure  => link,
    require => Package[$aloha::common::nginx],
    target  => '/etc/nginx/sites-available/aloha-enterprise',
    notify  => Service['nginx'],
  }

  # We used to install a cron job, but certbot now has a systemd cron
  # that does better.  This can be removed once upgrading from 5.0 is
  # no longer possible.
  file { '/etc/cron.d/certbot-renew':
    ensure => absent,
  }

  # Reload nginx after deploying a new cert.
  file { ['/etc/letsencrypt/renewal-hooks', '/etc/letsencrypt/renewal-hooks/deploy']:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[certbot],
  }
  file { '/etc/letsencrypt/renewal-hooks/deploy/001-nginx.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/aloha/letsencrypt/nginx-deploy-hook.sh',
    require => Package[certbot],
  }
  if ! $nginx_http_only {
      exec { 'fix-standalone-certbot':
        onlyif  => @(EOT),
          test -L /etc/ssl/certs/aloha.combined-chain.crt &&
          readlink /etc/ssl/certs/aloha.combined-chain.crt | grep -q /etc/letsencrypt/live/ &&
          test -d /etc/letsencrypt/renewal &&
          grep -qx "authenticator = standalone" /etc/letsencrypt/renewal/*.conf
          | EOT
        command => "${::aloha_scripts_path}/lib/fix-standalone-certbot",
      }
  }

  # Restart the server regularly to avoid potential memory leak problems.
  file { '/etc/cron.d/restart-aloha':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/restart-aloha',
  }
}
