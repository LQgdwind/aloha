class aloha::nginx {
  $web_packages = [
    # Needed to run nginx with the modules we use
    $aloha::common::nginx,
    'ca-certificates',
  ]
  package { $web_packages: ensure => installed }

  if $::os['family'] == 'RedHat' {
    file { '/etc/nginx/sites-available':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
    }
    file { '/etc/nginx/sites-enabled':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
    }
  }

  file { '/etc/nginx/aloha-include/':
    require => Package[$aloha::common::nginx],
    recurse => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/nginx/aloha-include-common/',
    notify  => Service['nginx'],
  }

  # Configuration for how uploaded files and profile pictures are
  # served.  The default is to serve uploads using using the `nginx`
  # `internal` feature via django-sendfile2, which basically does an
  # internal redirect and returns the file content from nginx in an
  # HttpResponse that would otherwise have been a redirect.  Profile
  # pictures are served directly off disk.
  #
  # For installations using S3 to serve uploaded files, we want Django
  # to handle the /serve_uploads and /user_avatars routes, so that it
  # can serve a redirect (after doing authentication, for uploads).
  $no_serve_uploads = alohaconf('application_server', 'no_serve_uploads', false)
  if $no_serve_uploads {
    file { '/etc/nginx/aloha-include/app.d/uploads-internal.conf':
      ensure  => absent,
    }
  } else {
    file { '/etc/nginx/aloha-include/app.d/uploads-internal.conf':
      ensure  => file,
      require => Package[$aloha::common::nginx],
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Service['nginx'],
      source  => 'puppet:///modules/aloha/nginx/aloha-include-maybe/uploads-internal.conf',
    }
  }

  # TODO/compatibility: Removed 2021-04 in Aloha 4.0; these lines can
  # be removed once one must have upgraded through Aloha 4.0 or higher
  # to get to the next release.
  file { '/etc/nginx/aloha-include/uploads.route':
    ensure  => absent,
  }

  # TODO/compatibility: Removed 2021-05 in Aloha 4.0; these lines can
  # be removed once one must have upgraded through Aloha 4.0 or higher
  # to get to the next release.
  file { '/etc/nginx/aloha-include/app.d/thumbor.conf':
    ensure  => absent,
  }

  file { '/etc/nginx/dhparam.pem':
    ensure  => file,
    require => Package[$aloha::common::nginx],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['nginx'],
    source  => 'puppet:///modules/aloha/nginx/dhparam.pem',
  }

  if $::os['family'] == 'Debian' {
      $ca_crt = '/etc/ssl/certs/ca-certificates.crt'
  } else {
      $ca_crt = '/etc/pki/tls/certs/ca-bundle.crt'
  }
  file { '/etc/nginx/nginx.conf':
    ensure  => file,
    require => Package[$aloha::common::nginx, 'ca-certificates'],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['nginx'],
    content => template('aloha/nginx.conf.template.erb'),
  }

  file { '/etc/nginx/uwsgi_params':
    ensure  => file,
    require => Package[$aloha::common::nginx],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['nginx'],
    source  => 'puppet:///modules/aloha/nginx/uwsgi_params',
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
    notify => Service['nginx'],
  }

  file { '/var/log/nginx':
    ensure => directory,
    owner  => 'aloha',
    group  => 'adm',
    mode   => '0650',
  }
  file { '/etc/logrotate.d/nginx':
    ensure  => file,
    require => Package[$aloha::common::nginx],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/logrotate/nginx',
  }
  package { 'certbot':
    ensure => installed,
  }
  file { ['/var/lib/aloha', '/var/lib/aloha/certbot-webroot']:
    ensure => directory,
    owner  => 'aloha',
    group  => 'adm',
    mode   => '0660',
  }

  service { 'nginx':
    ensure     => running,
  }
}
