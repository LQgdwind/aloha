# @summary Gathers Prometheus statistics from all nodes.
#
# Only one instance is necessary.
#
class aloha_ops::profile::prometheus_server {
  include aloha_ops::profile::base
  include aloha_ops::prometheus::base

  $version = $aloha::common::versions['prometheus']['version']
  $dir = "/srv/aloha-prometheus-${version}"
  $bin = "${dir}/prometheus"
  $data_dir = '/var/lib/prometheus'

  aloha::external_dep { 'prometheus':
    version        => $version,
    url            => "https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-${aloha::common::goarch}.tar.gz",
    tarball_prefix => "prometheus-${version}.linux-${aloha::common::goarch}",
  }
  file { '/usr/local/bin/promtool':
    ensure  => link,
    target  => "${dir}/promtool",
    require => aloha::External_Dep['prometheus'],
  }
  # This was moved to an external dep in 2021/12, and the below can be
  # removed once the prod server has taken the update.
  file { '/srv/prometheus':
    ensure => absent,
  }

  file { $data_dir:
    ensure  => directory,
    owner   => 'prometheus',
    group   => 'prometheus',
    require => [ User[prometheus], Group[prometheus] ],
  }
  file { '/etc/prometheus':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  file { '/etc/prometheus/prometheus.yaml':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/prometheus/prometheus.yaml',
    notify => Service[supervisor],
  }

  file { "${aloha::common::supervisor_conf_dir}/prometheus.conf":
    ensure  => file,
    require => [
      Package[supervisor],
      aloha::External_Dep['prometheus'],
      File[$data_dir],
      File['/etc/prometheus/prometheus.yaml'],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha_ops/supervisor/conf.d/prometheus.conf.template.erb'),
    notify  => Service[supervisor],
  }
}
