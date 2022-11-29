# This class includes all the modules you need to run an entire Aloha
# installation on a single server.  If desired, you can split up the
# different `aloha::profile::*` components of a Aloha installation on
# different servers by using the modules below on different machines
# (the module list is stored in `puppet_classes` in
# /etc/aloha/aloha.conf).  See the corresponding configuration in
# /etc/aloha/settings.py for how to find the various services is also
# required to make this work.
class aloha::profile::standalone {
  include aloha::profile::base
  include aloha::profile::app_frontend
  include aloha::profile::postgresql
  include aloha::profile::redis
  include aloha::profile::memcached
  include aloha::profile::rabbitmq
  include aloha::localhost_camo
  include aloha::static_asset_compiler
}
