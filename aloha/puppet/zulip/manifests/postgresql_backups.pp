# @summary Use wal-g to take daily backups of PostgreSQL
#
class aloha::postgresql_backups {
  include aloha::postgresql_common
  include aloha::wal_g

  file { '/usr/local/bin/pg_backup_and_purge':
    ensure  => file,
    owner   => 'root',
    group   => 'postgres',
    mode    => '0754',
    source  => 'puppet:///modules/aloha/postgresql/pg_backup_and_purge',
    require => [
      File['/usr/local/bin/env-wal-g'],
      Package[
        $aloha::postgresql_common::postgresql,
        'python3-dateutil',
      ],
    ],
  }

  # Aloha 4.x and before used the `cron` resource here, which placed
  # this in the postgres user's crontab, which was not discoverable.
  # Removed 2021-11 in version 5.0; these lines can be removed when we
  # drop support for upgrading from Aloha 4 or older.
  cron { 'pg_backup_and_purge':
    ensure      => absent,
    command     => '/usr/local/bin/pg_backup_and_purge',
    environment => 'PATH=/bin:/usr/bin:/usr/local/bin',
    hour        => 2,
    minute      => 0,
    target      => 'postgres',
    user        => 'postgres',
  }
  file { '/etc/cron.d/pg_backup_and_purge':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/cron.d/pg-backup-and-purge',
    require => File['/usr/local/bin/pg_backup_and_purge'],
  }

  file { "${aloha::common::nagios_plugins_dir}/aloha_postgresql_backups":
    require => Package[$aloha::common::nagios_plugins],
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/aloha/nagios_plugins/aloha_postgresql_backups',
  }
}
