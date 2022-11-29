class aloha_ops::teleport::base {
  include aloha::supervisor

  $setup_apt_repo_file = "${::aloha_scripts_path}/lib/setup-apt-repo"
  exec{ 'setup-apt-repo-teleport':
    command => "${setup_apt_repo_file} --list teleport",
    unless  => "${setup_apt_repo_file} --list teleport --verify",
  }
  Package { 'teleport':
    require => Exec['setup-apt-repo-teleport'],
  }
}
