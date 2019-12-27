#!/usr/bin/env bash

[[ "$EUID" == 0 ]] || { echo "This script requires root." && exit 1; }
set -ex

if systemctl -q is-active zram-swap.service; then
  systemctl stop zram-swap.service
fi

install -o root zram-swap.sh /usr/local/sbin/zram-swap.sh
if [[ -f /etc/default/zram-swap-service ]]; then
  mv -f /etc/default/zram-swap-service /etc/default/zram-swap
  chmod 0644 /etc/default/zram-swap
else
  install -o root -m 0644 service/zram-swap.config /etc/default/zram-swap
fi
install -o root -m 0644 service/zram-swap.service /etc/systemd/system/zram-swap.service

systemctl daemon-reload
systemctl enable zram-swap.service
systemctl start zram-swap.service
