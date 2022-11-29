class aloha_ops::profile::smokescreen {
  include aloha_ops::profile::base

  include aloha::profile::smokescreen
  aloha_ops::firewall_allow { 'smokescreen': port => '4750' }

  include aloha_ops::camo
}
