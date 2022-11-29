class aloha_ops::camo {
  class { 'aloha::camo':
    listen_address => '0.0.0.0',
  }

  aloha_ops::firewall_allow { 'camo': port => '9292' }
}
