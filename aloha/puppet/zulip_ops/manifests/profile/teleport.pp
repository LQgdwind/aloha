class aloha_ops::profile::teleport {
  include aloha_ops::profile::base

  file { '/etc/teleport_server.yaml':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/teleport_server.yaml',
  }
  file { "${aloha::common::supervisor_conf_dir}/teleport_server.conf":
    ensure  => file,
    require => [ Package[supervisor], Package[teleport], File['/etc/teleport_server.yaml'] ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/aloha_ops/supervisor/conf.d/teleport_server.conf',
    notify  => Service[$aloha::common::supervisor_service],
  }

  # https://goteleport.com/docs/admin-guide/#ports
  # Port 443 is outward-facing, for UI
  aloha_ops::firewall_allow { 'teleport_server_ui': port => 443 }
  # Port 3023 is outward-facing, for teleport clients to connect to.
  aloha_ops::firewall_allow { 'teleport_server_proxy': port => 3023 }
  # Port 3034 is outward-facing, for teleport servers outside the
  # cluster to connect back to establish reverse proxies.
  aloha_ops::firewall_allow { 'teleport_server_reverse': port => 3024 }
  # Port 3025 is inward-facing, for other nodes to look up auth information
  aloha_ops::firewall_allow { 'teleport_server_auth': port => 3025 }
}
