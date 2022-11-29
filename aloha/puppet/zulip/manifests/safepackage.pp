define aloha::safepackage ( $ensure = present ) {
  if !defined(Package[$title]) {
    package { $title: ensure => $ensure }
  }
}
