#!/usr/bin/env bash

[[ "$EUID" == 0 ]] || { echo "This script requires root." && exit 1; }
set -ex

if systemctl -q is-active zram-swap.service; then
  systemctl stop zram-swap.service
fi

install -o root zram-swap.sh /usr/local/sbin/zram-swap.sh
install -o root zram-swap-service /etc/default/zram-swap-service
install -o root zram-swap.service /etc/systemd/system/zram-swap.service

systemctl daemon-reload
systemctl enable zram-swap.service
systemctl start zram-swap.service
