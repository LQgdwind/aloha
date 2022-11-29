# This class includes all the modules you need to install/run a Aloha installation
# in a single container (without the database, memcached, Redis services).
# The database, memcached, Redis services need to be run in separate containers.
# Through this split of services, it is easier to scale the services to the needs.
class aloha::profile::docker {
  include aloha::profile::base
  include aloha::profile::app_frontend
  include aloha::localhost_camo
  include aloha::supervisor
  include aloha::process_fts_updates

  file { "${aloha::common::supervisor_conf_dir}/cron.conf":
    ensure  => file,
    require => Package[supervisor],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/supervisor/conf.d/cron.conf',
  }
  file { "${aloha::common::supervisor_conf_dir}/nginx.conf":
    ensure  => file,
    require => Package[supervisor],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/supervisor/conf.d/nginx.conf',
  }
}
