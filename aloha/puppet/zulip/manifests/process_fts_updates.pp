class aloha::process_fts_updates {
  include aloha::supervisor
  case $::os['family'] {
    'Debian': {
      $fts_updates_packages = [
        # Needed to run process_fts_updates
        'python3-psycopg2', # TODO: use a virtualenv instead
      ]
      aloha::safepackage { $fts_updates_packages: ensure => installed }
    }
    'RedHat': {
      exec {'pip_process_fts_updates':
        command => 'python3 -m pip install psycopg2',
      }
    }
    default: {
      fail('osfamily not supported')
    }
  }

  file { '/usr/local/bin/process_fts_updates':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/aloha/postgresql/process_fts_updates',
  }

  file { "${aloha::common::supervisor_conf_dir}/aloha_db.conf":
    ensure  => file,
    require => [Package[supervisor], Package['python3-psycopg2']],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/supervisor/conf.d/aloha_db.conf',
    notify  => Service[$aloha::common::supervisor_service],
  }
}
