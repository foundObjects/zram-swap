# zram-swap
Simple zram swap setup + teardown script with systemd unit &amp; /etc/default configuration

https://github.com/foundObjects/zram-swap

### Installation

```
git clone https://github.com/foundObjects/zram-swap.git
cd zram-swap && sudo bash install.sh
```

### Usage

zram-swap.service will be started automatically during boot.

The default allocation creates a zram device that should use around half of physical memory when completely full.

Edit `/etc/default/zram-swap-service` if you'd like to change compression algorithms or swap allocation and then restart zram-swap with `systemctl restart zram-swap.service`.

Run `zramctl` during use to monitor swap compression and real memory usage.

### Debugging

Start zram-swap.sh with `bash -x zram-swap.sh (start|stop)` or `./zram-swap.sh -x (start|stop)` to see what's going wrong.

To dump the full execution trace during service start/stop edit  /etc/systemd/systemd/zram-swap.service and add -x to the following two lines:

```
ExecStart=/usr/local/sbin/zram-swap.sh -x init
ExecStop=/usr/local/sbin/zram-swap.sh -x  end
```
