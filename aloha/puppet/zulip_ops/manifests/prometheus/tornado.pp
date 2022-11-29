# @summary Prometheus monitoring of tornado processes
#
class aloha_ops::prometheus::tornado {
  $version = $aloha::common::versions['process_exporter']['version']
  $dir = "/srv/aloha-process_exporter-${version}"
  $bin = "${dir}/process-exporter"
  $conf = '/etc/aloha/tornado_process_exporter.yaml'

  aloha::external_dep { 'process_exporter':
    version        => $version,
    url            => "https://github.com/ncabatoff/process-exporter/releases/download/v${version}/process-exporter-${version}.linux-${aloha::common::goarch}.tar.gz",
    tarball_prefix => "process-exporter-${version}.linux-${aloha::common::goarch}",
  }

  aloha_ops::firewall_allow { 'tornado_exporter': port => '9256' }
  file { $conf:
    ensure  => file,
    require => User[aloha],
    owner   => 'aloha',
    group   => 'aloha',
    mode    => '0644',
    source  => 'puppet:///modules/aloha_ops/tornado_process_exporter.yaml',
  }
  file { "${aloha::common::supervisor_conf_dir}/prometheus_tornado_exporter.conf":
    ensure  => file,
    require => [
      User[aloha],
      Package[supervisor],
      aloha::External_Dep['process_exporter'],
      File[$conf],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha_ops/supervisor/conf.d/prometheus_tornado_exporter.conf.template.erb'),
    notify  => Service[supervisor],
  }
}
