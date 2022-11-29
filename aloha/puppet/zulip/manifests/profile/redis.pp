class aloha::profile::redis {
  include aloha::profile::base
  case $::os['family'] {
    'Debian': {
      $redis = 'redis-server'
      $redis_dir = '/etc/redis'
    }
    'RedHat': {
      $redis = 'redis'
      $redis_dir = '/etc'
    }
    default: {
      fail('osfamily not supported')
    }
  }
  $redis_packages = [ # The server itself
                      $redis,
                      ]

  package { $redis_packages: ensure => installed }

  $file = "${redis_dir}/redis.conf"
  $aloha_redisconf = "${redis_dir}/aloha-redis.conf"
  $line = "include ${aloha_redisconf}"
  exec { 'redis':
    unless  => "/bin/grep -Fxqe '${line}' '${file}'",
    path    => '/bin',
    command => "bash -c \"(/bin/echo; /bin/echo '# Include Aloha-specific configuration'; /bin/echo '${line}') >> '${file}'\"",
    require => [Package[$redis],
                File[$aloha_redisconf],
                Exec['rediscleanup-zuli-redis']],
  }

  # Fix the typo in the path to $aloha_redisconf introduced in
  # 071e32985c1207f20043e1cf28f82300d9f23f31 without triggering a
  # redis restart.
  $legacy_wrong_filename = "${redis_dir}/zuli-redis.conf"
  exec { 'rediscleanup-zuli-redis':
    onlyif   => "test -e ${legacy_wrong_filename}",
    command  => "
      mv ${legacy_wrong_filename} ${aloha_redisconf}
      perl -0777 -pe '
        if (m|^\\Q${line}\\E\$|m) {
          s|^\\n?(:?# Include Aloha-specific configuration\\n)?include \\Q${legacy_wrong_filename}\\E\\n||m;
        } else {
          s|^include \\Q${legacy_wrong_filename}\\E\$|${line}|m;
        }
      ' -i /etc/redis/redis.conf
    ",
    provider => shell,
  }

  $redis_password = alohasecret('secrets', 'redis_password', '')
  file { $aloha_redisconf:
    ensure  => file,
    require => [Package[$redis], Exec['rediscleanup-zuli-redis']],
    owner   => 'redis',
    group   => 'redis',
    mode    => '0640',
    content => template('aloha/aloha-redis.template.erb'),
  }

  file { '/run/redis':
    ensure  => directory,
    owner   => 'redis',
    group   => 'redis',
    mode    => '0755',
    require => Package[$redis],
  }
  service { $redis:
    ensure    => running,
    require   => File['/run/redis'],
    subscribe => [
      File[$aloha_redisconf],
      Exec['redis'],
    ],
  }
}
