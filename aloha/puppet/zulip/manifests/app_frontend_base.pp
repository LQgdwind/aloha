# Minimal configuration to run a Aloha application server.
# Default nginx configuration is included in extension app_frontend.pp.
class aloha::app_frontend_base {
  include aloha::nginx
  include aloha::sasl_modules
  include aloha::supervisor
  include aloha::tornado_sharding

  if $::os['family'] == 'Debian' {
    # Upgrade and other tooling wants to be able to get a database
    # shell.  This is not necessary on CentOS because the PostgreSQL
    # package already includes the client.  This may get us a more
    # recent client than the database server is configured to be,
    # ($aloha::postgresql_common::version), but they're compatible.
    aloha::safepackage { 'postgresql-client': ensure => installed }
  }
  # For Slack import
  aloha::safepackage { 'unzip': ensure => installed }

  file { '/etc/nginx/aloha-include/app':
    require => Package[$aloha::common::nginx],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/nginx/aloha-include-frontend/app',
    notify  => Service['nginx'],
  }
  file { '/etc/nginx/aloha-include/uploads.types':
    require => Package[$aloha::common::nginx],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/nginx/aloha-include-frontend/uploads.types',
    notify  => Service['nginx'],
  }
  file { '/etc/nginx/aloha-include/app.d/':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $loadbalancers = split(alohaconf('loadbalancer', 'ips', ''), ',')
  if $loadbalancers != [] {
    file { '/etc/nginx/aloha-include/app.d/accept-loadbalancer.conf':
      require => File['/etc/nginx/aloha-include/app.d'],
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('aloha/accept-loadbalancer.conf.template.erb'),
      notify  => Service['nginx'],
    }
    file { '/etc/nginx/aloha-include/app.d/keepalive-loadbalancer.conf':
      require => File['/etc/nginx/aloha-include/app.d'],
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/aloha/nginx/aloha-include-app.d/keepalive-loadbalancer.conf',
      notify  => Service['nginx'],
    }
  }

  file { '/etc/nginx/aloha-include/upstreams':
    require => Package[$aloha::common::nginx],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/nginx/aloha-include-frontend/upstreams',
    notify  => Service['nginx'],
  }

  # This determines whether we run queue processors multithreaded or
  # multiprocess.  Multiprocess scales much better, but requires more
  # RAM; we just auto-detect based on available system RAM.
  $queues_multiprocess_default = $aloha::common::total_memory_mb > 3500
  $queues_multiprocess = alohaconf('application_server', 'queue_workers_multiprocess', $queues_multiprocess_default)
  $queues = [
    'deferred_work',
    'digest_emails',
    'email_mirror',
    'embed_links',
    'embedded_bots',
    'error_reports',
    'invites',
    'email_senders',
    'missedmessage_emails',
    'missedmessage_mobile_notifications',
    'outgoing_webhooks',
    'user_activity',
    'user_activity_interval',
    'user_presence',
  ]
  if $queues_multiprocess {
    $uwsgi_default_processes = 6
  } else {
    $uwsgi_default_processes = 4
  }
  $tornado_ports = $aloha::tornado_sharding::tornado_ports

  $proxy_host = alohaconf('http_proxy', 'host', 'localhost')
  $proxy_port = alohaconf('http_proxy', 'port', '4750')

  if ($proxy_host in ['localhost', '127.0.0.1', '::1']) and ($proxy_port == '4750') {
    include aloha::smokescreen
  }

  if $proxy_host != '' and $proxy_port != '' {
    $proxy = "http://${proxy_host}:${proxy_port}"
  } else {
    $proxy = ''
  }
  file { "${aloha::common::supervisor_conf_dir}/aloha.conf":
    ensure  => file,
    require => [Package[supervisor], Exec['stage_updated_sharding']],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha/supervisor/aloha.conf.template.erb'),
    notify  => Service[$aloha::common::supervisor_service],
  }

  $uwsgi_listen_backlog_limit = alohaconf('application_server', 'uwsgi_listen_backlog_limit', 128)
  $uwsgi_processes = alohaconf('application_server', 'uwsgi_processes', $uwsgi_default_processes)
  $somaxconn = 2 * Integer($uwsgi_listen_backlog_limit)
  file { '/etc/aloha/uwsgi.ini':
    ensure  => file,
    require => Package[supervisor],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha/uwsgi.ini.template.erb'),
    notify  => Service[$aloha::common::supervisor_service],
  }
  file { '/etc/sysctl.d/40-uwsgi.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha/sysctl.d/40-uwsgi.conf.erb'),
  }
  exec { 'sysctl_p_uwsgi':
    command     => '/sbin/sysctl -p /etc/sysctl.d/40-uwsgi.conf',
    subscribe   => File['/etc/sysctl.d/40-uwsgi.conf'],
    refreshonly => true,
    # We have to protect against running in Docker and other
    # containerization which prevents adjusting these.
    onlyif      => 'touch /proc/sys/net/core/somaxconn',
  }

  file { '/home/aloha/tornado':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
    mode   => '0755',
  }
  file { '/home/aloha/logs':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
  }
  file { '/home/aloha/prod-static':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
  }
  file { '/home/aloha/deployments':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
  }
  file { '/srv/aloha-npm-cache':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
    mode   => '0755',
  }
  file { '/srv/aloha-emoji-cache':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
    mode   => '0755',
  }

  file { '/var/log/aloha/queue_error':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
    mode   => '0640',
  }

  file { '/var/log/aloha/queue_stats':
    ensure => directory,
    owner  => 'aloha',
    group  => 'aloha',
    mode   => '0640',
  }

  file { "${aloha::common::nagios_plugins_dir}/aloha_app_frontend":
    require => Package[$aloha::common::nagios_plugins],
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/aloha/nagios_plugins/aloha_app_frontend',
  }

  # This cron job does nothing unless RATE_LIMIT_TOR_TOGETHER is enabled.
  file { '/etc/cron.d/fetch-tor-exit-nodes':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/fetch-tor-exit-nodes',
  }
  # This was originally added with a typo in the name.
  file { '/etc/cron.d/fetch-for-exit-nodes':
    ensure => absent,
  }
}
