# @summary Outgoing HTTP CONNECT proxy for HTTP/HTTPS on port 4750.
#
class aloha::profile::smokescreen {
  include aloha::profile::base
  include aloha::smokescreen
}
