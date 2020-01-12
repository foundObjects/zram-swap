# zram-swap
Simple zram swap setup + teardown script for modern systemd Linux systems

https://github.com/foundObjects/zram-swap

### Why?

There are dozens of zram swap scripts out there, but most of them are overly
complicated and do things that haven't been neccessary since linux 3.X or have
massive logic errors in their swap size calculations. This script is simple and
reliable, modern and easy to configure.

### Installation

```
git clone https://github.com/foundObjects/zram-swap.git
cd zram-swap && sudo ./install.sh
```

### Usage

zram-swap.service will be started automatically after installation and during
each subsequent boot. The default allocation creates a zram device that should
use around half of physical memory when completely full.

The default configuration using lz4 should work well for most people. lzo may
provide slightly better RAM utilization at a cost of slightly more expensive
decompression. zstd should provide better compression than lz* and still be
moderately fast on most machines. On very modern kernels the best overall
choice is probably lzo-rle.

Edit `/etc/default/zram-swap` if you'd like to change compression algorithms or
swap allocation and then restart zram-swap with `systemctl restart
zram-swap.service`.

Run `zramctl` during use to monitor swap compression and real memory usage.

### Debugging

Start zram-swap.sh with `zram-swap.sh -x (start|stop)` to view the debug trace
and determine what's going wrong.

To dump the full execution trace during service start/stop edit
`/etc/systemd/systemd/zram-swap.service` and add -x to the following two lines:

```
ExecStart=/usr/local/sbin/zram-swap.sh -x init
ExecStop=/usr/local/sbin/zram-swap.sh -x  end
```

### Compatibility

This should run on pretty much any recent (4.0+? kernel) Linux system using
systemd. If anyone wants to try it on something really old and let me know how
far back compatibility goes I'm interested, but I don't have any legacy systems
to test on at the moment.

The script will also work on non-systemd Linux without issue and I welcome PRs
supporting SysVinit.
