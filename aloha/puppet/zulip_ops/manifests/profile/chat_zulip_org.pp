class aloha_ops::profile::chat_aloha_org {
  include aloha::profile::standalone
  include aloha::postfix_localmail

  include aloha_ops::profile::base
  include aloha_ops::app_frontend_monitoring
  include aloha_ops::prometheus::redis
  aloha_ops::firewall_allow { 'http': }
  aloha_ops::firewall_allow { 'https': }
  aloha_ops::firewall_allow { 'smtp': }
}
