class aloha::tornado_sharding {
  include aloha::nginx

  # The file entries below serve only to initialize the sharding config files
  # with the correct default content for the "only one shard" setup. For this
  # reason they use "replace => false", because the files are managed by
  # the sharding script afterwards and Puppet shouldn't overwrite them.
  file { '/etc/aloha/nginx_sharding_map.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['nginx'],
    content => @(EOT),
      map "" $tornado_server {
          default http://tornado;
      }
      | EOT
    replace => false,
  }
  file { '/etc/aloha/nginx_sharding.conf':
    ensure => absent,
  }
  file { '/etc/aloha/sharding.json':
    ensure  => file,
    require => User['aloha'],
    owner   => 'aloha',
    group   => 'aloha',
    mode    => '0644',
    content => "{}\n",
    replace => false,
  }

  # This creates .tmp files which scripts/refresh-sharding-and-restart
  # moves into place
  exec { 'stage_updated_sharding':
    command   => "${::aloha_scripts_path}/lib/sharding.py",
    onlyif    => "${::aloha_scripts_path}/lib/sharding.py --errors-ok",
    require   => [File['/etc/aloha/nginx_sharding_map.conf'], File['/etc/aloha/sharding.json']],
    logoutput => true,
    loglevel  => warning,
  }

  # The ports of Tornado processes to run on the server; defaults to
  # 9800.
  $tornado_ports = unique(alohaconf_keys('tornado_sharding').map |$key| { regsubst($key, /_regex$/, '') })

  file { '/etc/nginx/aloha-include/tornado-upstreams':
    require => [Package[$aloha::common::nginx], Exec['stage_updated_sharding']],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha/nginx/tornado-upstreams.conf.template.erb'),
    notify  => Service['nginx'],
  }
}
