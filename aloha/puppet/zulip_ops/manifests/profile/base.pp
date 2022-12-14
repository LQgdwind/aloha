class aloha_ops::profile::base {
  include aloha::profile::base
  include aloha_ops::munin_node
  include aloha_ops::ksplice_uptrack
  include aloha_ops::firewall
  include aloha_ops::teleport::node
  include aloha_ops::prometheus::node

  aloha_ops::firewall_allow { 'ssh': order => '10'}

  $org_base_packages = [
    # Standard kernel, not AWS', so ksplice works
    'linux-image-virtual',
    # Management for our systems
    'openssh-server',
    'mosh',
    # package management
    'aptitude',
    # SSL certificates
    'certbot',
    # For managing our current Debian packages
    'debian-goodies',
    # Popular editors
    'vim',
    'emacs-nox',
    # Prevent accidental reboots
    'molly-guard',
    # Useful tools in a production environment
    'screen',
    'strace',
    'bind9-host',
    'git',
    'nagios-plugins-contrib',
  ]
  aloha::safepackage { $org_base_packages: ensure => installed }

  # Uninstall the AWS kernel, but only after we install the usual one
  package { ['linux-image-aws', 'linux-headers-aws', 'linux-aws-*', 'linux-image-*-aws', 'linux-modules-*-aws']:
    ensure  => absent,
    require => Package['linux-image-virtual'],
  }

  file { '/etc/apt/apt.conf.d/02periodic':
    ensure => file,
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/apt/apt.conf.d/02periodic',
  }

  file { '/etc/apt/apt.conf.d/50unattended-upgrades':
    ensure => file,
    mode   => '0644',
    source => 'puppet:///modules/aloha_ops/apt/apt.conf.d/50unattended-upgrades',
  }
  if $::os['distro']['release']['major'] == '22.04' {
    file { '/etc/needrestart/conf.d/aloha.conf':
      ensure => file,
      mode   => '0644',
      source => 'puppet:///modules/aloha_ops/needrestart/aloha.conf',
    }
  }

  file { '/home/aloha/.ssh':
    ensure  => directory,
    require => User['aloha'],
    owner   => 'aloha',
    group   => 'aloha',
    mode    => '0600',
  }

  # Clear /etc/update-motd.d, to fix load problems with Nagios
  # caused by Ubuntu's default MOTD tools for things like "checking
  # for the next release" being super slow.
  file { '/etc/update-motd.d':
    ensure  => directory,
    recurse => true,
    purge   => true,
  }

  file { '/etc/pam.d/common-session':
    ensure  => file,
    require => Package['openssh-server'],
    source  => 'puppet:///modules/aloha_ops/common-session',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'ssh':
    ensure     => running,
  }

  file { '/etc/ssh/sshd_config':
    ensure  => file,
    require => Package['openssh-server'],
    source  => 'puppet:///modules/aloha_ops/sshd_config',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['ssh'],
  }

  file { '/root/.emacs':
    ensure => file,
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/aloha_ops/dot_emacs.el',
  }

  file { '/home/aloha/.emacs':
    ensure  => file,
    mode    => '0600',
    owner   => 'aloha',
    group   => 'aloha',
    source  => 'puppet:///modules/aloha_ops/dot_emacs.el',
    require => User['aloha'],
  }

  $hosting_provider = alohaconf('machine', 'hosting_provider', 'ec2')
  if $hosting_provider == 'ec2' {
    # This conditional block is for for whether it's not
    # chat.aloha.org, which uses a different hosting provider.
    file { '/root/.ssh/authorized_keys':
      ensure => file,
      mode   => '0600',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/aloha_ops/root_authorized_keys',
    }
    file { '/home/aloha/.ssh/authorized_keys':
      ensure  => file,
      require => File['/home/aloha/.ssh'],
      mode    => '0600',
      owner   => 'aloha',
      group   => 'aloha',
      source  => 'puppet:///modules/aloha_ops/authorized_keys',
    }
    file { '/var/lib/nagios/.ssh/authorized_keys':
      ensure  => file,
      require => File['/var/lib/nagios/.ssh'],
      mode    => '0600',
      owner   => 'nagios',
      group   => 'nagios',
      source  => 'puppet:///modules/aloha_ops/nagios_authorized_keys',
    }

    file { '/usr/local/sbin/aloha-ec2-configure-interfaces':
      ensure => absent,
    }

    file { '/etc/network/if-up.d/aloha-ec2-configure-interfaces_if-up.d.sh':
      ensure => absent,
    }

    file { '/etc/chrony/chrony.conf':
      ensure  => file,
      mode    => '0644',
      source  => 'puppet:///modules/aloha_ops/chrony.conf',
      require => Package['chrony'],
      notify  => Service['chrony'],
    }
  }

  group { 'nagios':
    ensure => present,
    gid    => '1050',
  }
  user { 'nagios':
    ensure     => present,
    uid        => '1050',
    gid        => '1050',
    shell      => '/bin/bash',
    home       => '/var/lib/nagios',
    managehome => true,
  }
  file { '/var/lib/nagios/':
    ensure  => directory,
    require => User['nagios'],
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0600',
  }
  file { '/var/lib/nagios/.ssh':
    ensure  => directory,
    require => File['/var/lib/nagios/'],
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0600',
  }
  file { '/home/nagios':
    ensure  => absent,
    force   => true,
    recurse => true,
  }
}
