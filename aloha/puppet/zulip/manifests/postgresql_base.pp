# Minimal shared configuration needed to run a Aloha PostgreSQL database.
class aloha::postgresql_base {
  include aloha::postgresql_common
  include aloha::process_fts_updates

  case $::os['family'] {
    'Debian': {
      $postgresql = "postgresql-${aloha::postgresql_common::version}"
      $postgresql_sharedir = "/usr/share/postgresql/${aloha::postgresql_common::version}"
      $postgresql_confdirs = [
        "/etc/postgresql/${aloha::postgresql_common::version}",
        "/etc/postgresql/${aloha::postgresql_common::version}/main",
      ]
      $postgresql_confdir = $postgresql_confdirs[-1]
      $postgresql_datadir = "/var/lib/postgresql/${aloha::postgresql_common::version}/main"
      $tsearch_datadir = "${postgresql_sharedir}/tsearch_data"
      $pgroonga_setup_sql_path = "${postgresql_sharedir}/pgroonga_setup.sql"
      $setup_system_deps = 'setup_apt_repo'
      $postgresql_restart = "pg_ctlcluster ${aloha::postgresql_common::version} main restart"
      $postgresql_dict_dict = '/var/cache/postgresql/dicts/en_us.dict'
      $postgresql_dict_affix = '/var/cache/postgresql/dicts/en_us.affix'
    }
    'RedHat': {
      $postgresql = "postgresql${aloha::postgresql_common::version}"
      $postgresql_sharedir = "/usr/pgsql-${aloha::postgresql_common::version}/share"
      $postgresql_confdirs = [
        "/var/lib/pgsql/${aloha::postgresql_common::version}",
        "/var/lib/pgsql/${aloha::postgresql_common::version}/data",
      ]
      $postgresql_confdir = $postgresql_confdirs[-1]
      $postgresql_datadir = "/var/lib/pgsql/${aloha::postgresql_common::version}/data"
      $tsearch_datadir = "${postgresql_sharedir}/tsearch_data/"
      $pgroonga_setup_sql_path = "${postgresql_sharedir}/pgroonga_setup.sql"
      $setup_system_deps = 'setup_yum_repo'
      $postgresql_restart = "systemctl restart postgresql-${aloha::postgresql_common::version}"
      # TODO Since we can't find the PostgreSQL dicts directory on CentOS yet, we
      # link directly to the hunspell directory.
      $postgresql_dict_dict = '/usr/share/myspell/en_US.dic'
      $postgresql_dict_affix = '/usr/share/myspell/en_US.aff'
    }
    default: {
      fail('osfamily not supported')
    }
  }

  file { "${tsearch_datadir}/en_us.dict":
    ensure  => link,
    require => Package[$postgresql],
    target  => $postgresql_dict_dict,
  }
  file { "${tsearch_datadir}/en_us.affix":
    ensure  => link,
    require => Package[$postgresql],
    target  => $postgresql_dict_affix,

  }
  file { "${tsearch_datadir}/aloha_english.stop":
    ensure  => file,
    require => Package[$postgresql],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/postgresql/aloha_english.stop',
  }
  file { "${aloha::common::nagios_plugins_dir}/aloha_postgresql":
    require => Package[$aloha::common::nagios_plugins],
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/aloha/nagios_plugins/aloha_postgresql',
  }

  $pgroonga = alohaconf('machine', 'pgroonga', false)
  if $pgroonga {
    # Needed for optional our full text search system

    # Removed 2020-12 in version 4.0; these lines can be removed when
    # we drop support for upgrading from Aloha 3 or older.
    package{"${postgresql}-pgroonga":
      ensure  => purged,
    }

    package{"${postgresql}-pgdg-pgroonga":
      ensure  => installed,
      require => [Package[$postgresql],
                  Exec[$setup_system_deps]],
    }

    $dbname = alohaconf('postgresql', 'database_name', 'aloha')
    $dbuser = alohaconf('postgresql', 'database_user', 'aloha')
    file { $pgroonga_setup_sql_path:
      ensure  => file,
      require => Package["${postgresql}-pgdg-pgroonga"],
      owner   => 'postgres',
      group   => 'postgres',
      mode    => '0640',
      content => template('aloha/postgresql/pgroonga_setup.sql.template.erb'),
    }

    exec{'create_pgroonga_extension':
      require => File[$pgroonga_setup_sql_path],
      # lint:ignore:140chars
      command => "bash -c 'cat ${pgroonga_setup_sql_path} | su postgres -c \"psql -v ON_ERROR_STOP=1 ${dbname}\" && touch ${pgroonga_setup_sql_path}.applied'",
      # lint:endignore
      creates => "${pgroonga_setup_sql_path}.applied",
    }
  }

  $s3_backups_bucket = alohasecret('secrets', 's3_backups_bucket', '')
  if $s3_backups_bucket != '' {
    include aloha::postgresql_backups
  }
}
