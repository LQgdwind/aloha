# @summary Prometheus monitoring of uwsgi servers
#
class aloha_ops::prometheus::uwsgi {
  $version = $aloha::common::versions['uwsgi_exporter']['version']
  $dir = "/srv/aloha-uwsgi_exporter-${version}"
  $bin = "${dir}/uwsgi_exporter"

  aloha::external_dep { 'uwsgi_exporter':
    version        => $version,
    url            => "https://github.com/timonwong/uwsgi_exporter/releases/download/v${version}/uwsgi_exporter-${version}.linux-${aloha::common::goarch}.tar.gz",
    tarball_prefix => "uwsgi_exporter-${version}.linux-${aloha::common::goarch}",
  }

  aloha_ops::firewall_allow { 'uwsgi_exporter': port => '9238' }
  file { "${aloha::common::supervisor_conf_dir}/prometheus_uwsgi_exporter.conf":
    ensure  => file,
    require => [
      User[aloha],
      Package[supervisor],
      aloha::External_Dep['uwsgi_exporter'],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha_ops/supervisor/conf.d/prometheus_uwsgi_exporter.conf.template.erb'),
    notify  => Service[supervisor],
  }
}
