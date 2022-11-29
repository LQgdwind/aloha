class aloha_ops::prod_app_frontend_once {
  include aloha::app_frontend_once

  file { '/etc/cron.d/update-first-visible-message-id':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/calculate-first-visible-message-id',
  }

  file { '/etc/cron.d/invoice-plans':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/invoice-plans',
  }

  file { '/etc/cron.d/downgrade-small-realms-behind-on-payments':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha/cron.d/downgrade-small-realms-behind-on-payments',
  }

  file { '/etc/cron.d/check_send_receive_time':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/cron.d/check_send_receive_time',
  }

  file { '/etc/cron.d/check_user_zephyr_mirror_liveness':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/cron.d/check_user_zephyr_mirror_liveness',
  }
}
