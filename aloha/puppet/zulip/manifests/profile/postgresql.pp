# @summary Extends postgresql_base by tuning the configuration.
class aloha::profile::postgresql {
  include aloha::profile::base
  include aloha::postgresql_base

  $work_mem = $aloha::common::total_memory_mb / 512
  $shared_buffers = $aloha::common::total_memory_mb / 8
  $effective_cache_size = $aloha::common::total_memory_mb * 10 / 32
  $maintenance_work_mem = $aloha::common::total_memory_mb / 32

  $random_page_cost = alohaconf('postgresql', 'random_page_cost', undef)
  $effective_io_concurrency = alohaconf('postgresql', 'effective_io_concurrency', undef)

  $listen_addresses = alohaconf('postgresql', 'listen_addresses', undef)

  $s3_backups_bucket = alohasecret('secrets', 's3_backups_bucket', '')
  $replication_primary = alohaconf('postgresql', 'replication_primary', undef)
  $replication_user = alohaconf('postgresql', 'replication_user', undef)
  $replication_password = alohasecret('secrets', 'postgresql_replication_password', '')

  $ssl_cert_file = alohaconf('postgresql', 'ssl_cert_file', undef)
  $ssl_key_file = alohaconf('postgresql', 'ssl_key_file', undef)
  $ssl_ca_file = alohaconf('postgresql', 'ssl_ca_file', undef)
  $ssl_mode = alohaconf('postgresql', 'ssl_mode', undef)

  file { $aloha::postgresql_base::postgresql_confdirs:
    ensure => directory,
    owner  => 'postgres',
    group  => 'postgres',
  }

  $postgresql_conf_file = "${aloha::postgresql_base::postgresql_confdir}/postgresql.conf"
  file { $postgresql_conf_file:
    ensure  => file,
    require => Package[$aloha::postgresql_base::postgresql],
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0644',
    content => template("aloha/postgresql/${aloha::postgresql_common::version}/postgresql.conf.template.erb"),
  }

  if $replication_primary != '' and $replication_user != '' {
    if $s3_backups_bucket == '' {
      $message = @(EOT/L)
          Replication is enabled, but s3_backups_bucket is not set in aloha-secrets.conf!  \
          Streaming replication requires wal-g backups be configured.
          |-EOT
      warning($message)
    }
    if $aloha::postgresql_common::version in ['11'] {
      # PostgreSQL 11 and below used a recovery.conf file for replication
      file { "${aloha::postgresql_base::postgresql_datadir}/recovery.conf":
        ensure  => file,
        require => Package[$aloha::postgresql_base::postgresql],
        owner   => 'postgres',
        group   => 'postgres',
        mode    => '0644',
        content => template('aloha/postgresql/recovery.conf.template.erb'),
      }
    } else {
      # PostgreSQL 12 and above use the presence of a standby.signal
      # file to trigger replication
      file { "${aloha::postgresql_base::postgresql_datadir}/standby.signal":
        ensure  => file,
        require => Package[$aloha::postgresql_base::postgresql],
        owner   => 'postgres',
        group   => 'postgres',
        mode    => '0644',
        content => '',
      }
    }
  }

  exec { $aloha::postgresql_base::postgresql_restart:
    require     => Package[$aloha::postgresql_base::postgresql],
    refreshonly => true,
    subscribe   => [ File[$postgresql_conf_file] ],
  }
}
