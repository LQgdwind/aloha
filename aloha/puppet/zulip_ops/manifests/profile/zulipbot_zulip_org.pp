class aloha_ops::profile::alohabot_aloha_org {
  include aloha_ops::profile::base
  aloha_ops::firewall_allow { 'http': }
  aloha_ops::firewall_allow { 'https': }

  # TODO: This does not do any configuration of alohabot itself, or of
  # caddy.
}
