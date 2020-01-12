#!/bin/sh

#[ "$(id -u)" -eq '0' ] || { echo "This script requires root." && exit 1; }
case "$(readlink /proc/$$/exe)" in */bash) set -euo pipefail ;; *) set -eu ;; esac

# ensure a predictable environment
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
\unalias -a

# installer main body:
_main() {
  # ensure $1 exists so 'set -u' doesn't error out
  [ "$#" -eq "0" ] && { set -- ""; } > /dev/null 2>&1

  case "$1" in
    "--uninstall")
      # uninstall, requires root
      assert_root
      _uninstall
      ;;
    "--install" | "")
      # install dpkg hooks, requires root
      assert_root
      _install "$@"
      ;;
    *)
      # unknown flags, print usage and exit
      _usage
      ;;
  esac
  exit 0
}

_install() {
  set -x
  oldconfig=''
  configdiff=''
  if systemctl -q is-active zram-swap.service; then
    echo "Stopping zram-swap service"
    systemctl stop zram-swap.service
  fi

  echo "Installing script and service"
  install -o root zram-swap.sh /usr/local/sbin/zram-swap.sh
  install -o root -m 0644 service/zram-swap.service /etc/systemd/system/zram-swap.service

  # rename & cleanup old version config file
  if [ -f /etc/default/zram-swap-service ]; then
    echo "Old config found, moving to new path"
    mv -f /etc/default/zram-swap-service /etc/default/zram-swap
    chown root:root /etc/default/zram-swap
    chmod 0644 /etc/default/zram-swap
  fi

  # TODO this really needs work... {{{
  if [ -f /etc/default/zram-swap ]; then
    #{ set +e; } >/dev/null 2>&1
    #diff /etc/default/zram-swap service/zram-swap.config > /dev/null 2>&1
    #[ "$?" -gt 0 ] && oldconfig='y'
    #{ set -e; } >/dev/null 2>&1
    {
      set +e
      # TODO only run diff once
      #configdiff=$(diff /etc/default/zram-swap service/zram-swap.config)
      diff /etc/default/zram-swap service/zram-swap.config
      [ "$?" -gt 0 ] && oldconfig='y'
      set -e
    } > /dev/null 2>&1
  fi
  install -o root -m 0644 -b service/zram-swap.config /etc/default/zram-swap

  echo "Reloading systemd unit files and enabling boot-time service"
  systemctl daemon-reload
  systemctl enable zram-swap.service
  if [ -n "$oldconfig" ]; then
    cat <<- HEREDOC
		Configuration file updated; old config saved as /etc/default/zram-swap~

		diff follows:
		$(diff /etc/default/zram-swap~ /etc/default/zram-swap || true)

		Make any desired changes to the new config and then start the service with
		systemctl start zram-swap.service
		HEREDOC
  else
    systemctl start zram-swap.service
  fi
  #}}}
}

_uninstall() {
  set -x
  if systemctl -q is-active zram-swap.service; then
    echo "Stopping zram-swap service"
    systemctl stop zram-swap.service
  fi

  echo "Uninstalling script and systemd service."
  if [ -f /etc/systemd/system/zram-swap.service ]; then
    systemctl disable zram-swap.service || true
    rm -f /etc/systemd/system/zram-swap.service
  fi
  if [ -f /usr/local/sbin/zram-swap.sh ]; then
    rm -f /usr/local/sbin/zram-swap.sh
  fi
  echo "Reloading systemd unit files"
  systemctl daemon-reload

  echo "zram-swap service uninstalled; remove configuration /etc/default/zram-swap if desired"
}

assert_root() { [ "$(id -u)" -eq '0' ] || { echo "This action requires root." && exit 1; }; }
_usage() { echo "Usage: $(basename "$0") (--install|--uninstall)"; }

_main "$@"
