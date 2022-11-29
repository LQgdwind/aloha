# Cron jobs and other tools that should run on only one Aloha server
# in a cluster.

class aloha::app_frontend_once {
  $proxy_host = alohaconf('http_proxy', 'host', 'localhost')
  $proxy_port = alohaconf('http_proxy', 'port', '4750')
  if $proxy_host != '' and $proxy_port != '' {
    $proxy = "http://${proxy_host}:${proxy_port}"
  } else {
    $proxy = ''
  }
  file { "${aloha::common::supervisor_conf_dir}/aloha-once.conf":
    ensure  => file,
    require => [Package[supervisor], Exec['stage_updated_sharding']],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha/supervisor/aloha-once.conf.template.erb'),
    notify  => Service[$aloha::common::supervisor_service],
  }

  file { '/etc/cron.d/send-digest-emails':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/send-digest-emails',
  }

  file { '/etc/cron.d/update-analytics-counts':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/update-analytics-counts',
  }

  file { '/etc/cron.d/check-analytics-state':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/check-analytics-state',
  }

  file { '/etc/cron.d/soft-deactivate-users':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/soft-deactivate-users',
  }

  file { '/etc/cron.d/promote-new-full-members':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/promote-new-full-members',
  }

  file { '/etc/cron.d/archive-messages':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/archive-messages',
  }

  file { '/etc/cron.d/clearsessions':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/clearsessions',
  }
}
