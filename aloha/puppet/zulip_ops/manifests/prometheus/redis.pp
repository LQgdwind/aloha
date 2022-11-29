# @summary Prometheus monitoring of redis servers
#
class aloha_ops::prometheus::redis {
  $version = $aloha::common::versions['redis_exporter']['version']
  $dir = "/srv/aloha-redis_exporter-${version}"
  $bin = "${dir}/redis_exporter"

  aloha::external_dep { 'redis_exporter':
    version        => $version,
    url            => "https://github.com/oliver006/redis_exporter/releases/download/v${version}/redis_exporter-v${version}.linux-${aloha::common::goarch}.tar.gz",
    tarball_prefix => "redis_exporter-v${version}.linux-${aloha::common::goarch}",
  }

  aloha_ops::firewall_allow { 'redis_exporter': port => '9121' }
  file { "${aloha::common::supervisor_conf_dir}/prometheus_redis_exporter.conf":
    ensure  => file,
    require => [
      User[aloha],
      Package[supervisor],
      aloha::External_Dep['redis_exporter'],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha_ops/supervisor/conf.d/prometheus_redis_exporter.conf.template.erb'),
    notify  => Service[supervisor],
  }
}
