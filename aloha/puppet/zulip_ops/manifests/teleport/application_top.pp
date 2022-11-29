# @summary Enables application support on the node; include once.
#
# See https://goteleport.com/docs/application-access/
class aloha_ops::teleport::application_top {
  concat::fragment { 'teleport_app':
    target => '/etc/teleport_node.yaml',
    order  => '10',
    source => 'puppet:///modules/aloha_ops/teleport_app.yaml',
  }
}
