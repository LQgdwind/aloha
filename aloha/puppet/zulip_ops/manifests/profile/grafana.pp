# @summary Observability using Grafana
#
class aloha_ops::profile::grafana {
  include aloha_ops::profile::base
  include aloha::supervisor

  $version = $aloha::common::versions['grafana']['version']
  $dir = "/srv/aloha-grafana-${version}"
  $bin = "${dir}/bin/grafana-server"
  $data_dir = '/var/lib/grafana'

  aloha::external_dep { 'grafana':
    version        => $version,
    url            => "https://dl.grafana.com/oss/release/grafana-${version}.linux-${aloha::common::goarch}.tar.gz",
    tarball_prefix => "grafana-${version}",
  }

  group { 'grafana':
    ensure => present,
    gid    => '1070',
  }
  user { 'grafana':
    ensure     => present,
    uid        => '1070',
    gid        => '1070',
    shell      => '/bin/bash',
    home       => $data_dir,
    managehome => false,
  }
  file { $data_dir:
    ensure  => directory,
    owner   => 'grafana',
    group   => 'grafana',
    require => [ User[grafana], Group[grafana] ],
  }
  file { '/var/log/grafana':
    ensure => directory,
    owner  => 'grafana',
    group  => 'grafana',
  }

  aloha_ops::teleport::application { 'monitoring': port => '3000' }
  aloha_ops::firewall_allow { 'grafana': port => '3000' }
  file { "${aloha::common::supervisor_conf_dir}/grafana.conf":
    ensure  => file,
    require => [
      Package[supervisor],
      aloha::External_Dep['grafana'],
      File[$data_dir],
      File['/var/log/grafana'],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha_ops/supervisor/conf.d/grafana.conf.erb'),
    notify  => Service[supervisor],
  }

  file { '/etc/grafana':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  file { '/etc/grafana/grafana.ini':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/grafana/grafana.ini',
    notify => Service[supervisor],
  }
}
