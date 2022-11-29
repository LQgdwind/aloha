class aloha::systemd_daemon_reload {
  exec { 'sh -c "! command -v systemctl > /dev/null || systemctl daemon-reload"':
    refreshonly => true,
  }
}
