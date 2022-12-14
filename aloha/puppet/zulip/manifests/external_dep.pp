define aloha::external_dep(
  String $version,
  String $url,
  String $tarball_prefix,
  String $sha256 = '',
) {
  if $sha256 == '' {
    if $aloha::common::versions[$title]['sha256'] =~ Hash {
      $sha256_filled = $aloha::common::versions[$title]['sha256'][$::os['architecture']]
      if $sha256_filled == undef {
        err("No sha256 found for ${title} for architecture ${::os['architecture']}")
        fail()
      }
    } else {
      # For things like source code which are arch-invariant
      $sha256_filled = $aloha::common::versions[$title]['sha256']
    }
  } else {
    $sha256_filled = $sha256
  }

  $dir = "/srv/aloha-${title}-${version}"

  aloha::sha256_tarball_to { $title:
    url     => $url,
    sha256  => $sha256_filled,
    install => {
      $tarball_prefix => $dir,
    },
  }

  file { $dir:
    ensure  => present,
    require => aloha::Sha256_Tarball_To[$title],
  }

  tidy { "/srv/aloha-${title}-*":
    path    => '/srv/',
    recurse => 1,
    rmdirs  => true,
    matches => "aloha-${title}-*",
    require => File[$dir],
  }
}
