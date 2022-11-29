# @summary Munin monitoring of a Django frontend and RabbitMQ server.
#
class aloha_ops::app_frontend_monitoring {
  include aloha_ops::prometheus::rabbitmq
  include aloha_ops::prometheus::uwsgi
  include aloha_ops::prometheus::tornado
  aloha_ops::firewall_allow { 'grok_exporter': port => '9144' }
  include aloha_ops::munin_node
  $munin_plugins = [
    'rabbitmq_connections',
    'rabbitmq_consumers',
    'rabbitmq_messages',
    'rabbitmq_messages_unacknowledged',
    'rabbitmq_messages_uncommitted',
    'rabbitmq_queue_memory',
    'aloha_send_receive_timing',
  ]
  aloha_ops::munin_plugin { $munin_plugins: }

  file { '/etc/cron.d/rabbitmq-monitoring':
    ensure  => file,
    require => Package[rabbitmq-server],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha/cron.d/rabbitmq-monitoring',
  }
}
