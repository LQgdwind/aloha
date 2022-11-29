# @summary go compiler and tools
#
class aloha::golang {
  $version = $aloha::common::versions['golang']['version']
  $dir = "/srv/aloha-golang-${version}"
  $bin = "${dir}/bin/go"

  aloha::external_dep { 'golang':
    version        => $version,
    url            => "https://golang.org/dl/go${version}.linux-${aloha::common::goarch}.tar.gz",
    tarball_prefix => 'go',
  }
}
