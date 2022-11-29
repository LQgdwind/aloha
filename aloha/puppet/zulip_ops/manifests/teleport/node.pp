# @summary Provide Teleport SSH access to a node.
#
# https://goteleport.com/docs/admin-guide/#adding-nodes-to-the-cluster
# details additional manual steps to allow a node to join the cluster.
class aloha_ops::teleport::node {
  include aloha_ops::teleport::base

  concat { '/etc/teleport_node.yaml':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  concat::fragment { 'teleport_node_base':
    target => '/etc/teleport_node.yaml',
    source => 'puppet:///modules/aloha_ops/teleport_node.yaml',
    order  => '01',
  }

  file { "${aloha::common::supervisor_conf_dir}/teleport_node.conf":
    ensure  => file,
    require => [
      Package[supervisor],
      Package[teleport],
      Concat['/etc/teleport_node.yaml'],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha_ops/supervisor/conf.d/teleport_node.conf',
    notify  => Service[$aloha::common::supervisor_service],
  }
}
