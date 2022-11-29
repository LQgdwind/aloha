class aloha::smokescreen {
  include aloha::supervisor
  include aloha::golang

  $version = $aloha::common::versions['smokescreen-src']['version']
  $dir = "/srv/aloha-smokescreen-src-${version}"
  $bin = "/usr/local/bin/smokescreen-${version}-go-${aloha::golang::version}"

  aloha::external_dep { 'smokescreen-src':
    version        => $version,
    url            => "https://github.com/stripe/smokescreen/archive/${version}.tar.gz",
    tarball_prefix => "smokescreen-${version}",
  }

  exec { 'compile smokescreen':
    command     => "${aloha::golang::bin} build -o ${bin}",
    cwd         => $dir,
    # GOCACHE is required; nothing is written to GOPATH, but it is required to be set
    environment => ['GOCACHE=/tmp/gocache', 'GOPATH=/root/go'],
    creates     => $bin,
    require     => [
      aloha::External_Dep['golang'],
      aloha::External_Dep['smokescreen-src'],
    ],
  }
  # This resource exists purely so it doesn't get tidied; it is
  # created by the 'compile smokescreen' step.
  file { $bin:
    ensure  => file,
    require => Exec['compile smokescreen'],
  }
  tidy { '/usr/local/bin/smokescreen-*':
    path    => '/usr/local/bin',
    recurse => 1,
    matches => 'smokescreen-*',
    require => Exec['compile smokescreen'],
  }

  $listen_address = alohaconf('http_proxy', 'listen_address', '127.0.0.1')
  file { "${aloha::common::supervisor_conf_dir}/smokescreen.conf":
    ensure  => file,
    require => [
      Package[supervisor],
      Exec['compile smokescreen'],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aloha/supervisor/smokescreen.conf.erb'),
    notify  => Service[supervisor],
  }
}
