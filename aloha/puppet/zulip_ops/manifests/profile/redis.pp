class aloha_ops::profile::redis inherits aloha_ops::profile::base {
  include aloha::profile::redis
  include aloha_ops::prometheus::redis

  # Need redis_password in its own file for Nagios
  file { '/var/lib/nagios/redis_password':
    ensure  => file,
    mode    => '0600',
    owner   => 'nagios',
    group   => 'nagios',
    content => "${aloha::profile::redis::redis_password}\n",
  }
}
