# zram-swap
A simple zram swap script and service for modern systemd Linux

https://github.com/foundObjects/zram-swap

### Why?

There are dozens of zram swap scripts; Unfortunately most are a bit crufty:
they generally don't handle errors well, or they implement obsolete performance
hacks from Linux 3.14 and almost all of them include logic errors in their
device size calculations.

I wrote zram-swap because I couldn't find a replacement for the Ubuntu
`zram-config` package that was simple, handled failures well, didn't make
mistakes with device sizes and kept its user-facing configuration
straightforward and easy to use.

### Installation

```bash
git clone https://github.com/foundObjects/zram-swap.git
cd zram-swap && sudo ./install.sh
```

### Usage

The installer will start the zram-swap.service automatically after installation
and enable service start during each subsequent boot. The default allocation
creates an lz4 zram device that should use around half of physical memory when
completely full.

The default configuration using lz4 should work well for most people. lzo may
provide slightly better RAM utilization at a cost of slightly more expensive
decompression. zstd should provide better compression than lz\* and still be
moderately fast on most machines. On very modern kernels and reasonably fast
hardware the best overall choice is probably lzo-rle.

I chose lz4 as the default to give low spec machines (some of the greatest
beneficiaries of swap on zram) whatever performance edge I could. While
lzo-rle is quite fast on modern hardware a machine like a Raspberry Pi 2B
needs every optimization advantage I can give it.

Edit `/etc/default/zram-swap` if you'd like to change compression algorithms or
swap allocation and then restart zram-swap with `systemctl restart
zram-swap.service`.

Run `zramctl` during use to monitor swap compression and real memory usage.

A very simple configuration that's expected to use up to 2GB RAM might look
something like:

```bash
# override fractional calculations and specify a fixed swap size
_zram_fixedsize="6G"

# compression algorithm to employ (lzo, lz4, zstd, lzo-rle)
_zram_algorithm="lzo-rle"
```

Remember that the ZRAM device size references uncompressed data, real memory
utilization should be 2-3x smaller than device size due to compression.

### Debugging

Start zram-swap.sh with `zram-swap.sh -x (start|stop)` to view the debug trace
and determine what's going wrong.

To dump the full execution trace during service start/stop edit
`/etc/systemd/systemd/zram-swap.service` and add -x to the following two lines:

```
ExecStart=/usr/local/sbin/zram-swap.sh -x start
ExecStop=/usr/local/sbin/zram-swap.sh -x stop
```

### Compatibility

Tested on Linux 4.4 through Linux 5.7.

This should run on pretty much any recent (4.0+? kernel) Linux system using
systemd. If anyone wants to try it on something really old and let me know how
compatible the script is with older systems I'm definitely interested, but I
don't have the legacy systems or time to test exhaustively.

The script itself should also be fully compatible with SysVinit compatible init
systems. PRs making improvement there are welcome!
