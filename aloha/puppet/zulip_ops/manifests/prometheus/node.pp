# @summary Configures a node for monitoring with Prometheus
#
class aloha_ops::prometheus::node {
  include aloha_ops::prometheus::base
  include aloha::supervisor

  $version = $aloha::common::versions['node_exporter']['version']
  $dir = "/srv/aloha-node_exporter-${version}"
  $bin = "${dir}/node_exporter"

  aloha::external_dep { 'node_exporter':
    version        => $version,
    url            => "https://github.com/prometheus/node_exporter/releases/download/v${version}/node_exporter-${version}.linux-${aloha::common::goarch}.tar.gz",
    tarball_prefix => "node_exporter-${version}.linux-${aloha::common::goarch}",
  }

  # This was moved to an external_dep in 2021/12, and these lines can
  # be removed once all prod hosts no longer have this file.
  file { '/usr/local/bin/node_exporter':
    ensure => absent,
  }

  aloha_ops::firewall_allow { 'node_exporter': port => '9100' }
  file { "${aloha::common::supervisor_conf_dir}/prometheus_node_exporter.conf":
    ensure  => file,
    require => [
      User[aloha],
      Package[supervisor],
      aloha::External_Dep['node_exporter'],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha_ops/supervisor/conf.d/prometheus_node_exporter.conf.template.erb'),
    notify  => Service[supervisor],
  }
}
