# zram-swap
A simple zram swap script and service for modern systemd Linux

https://github.com/foundObjects/zram-swap

### Why?

There are dozens of zram swap scripts; Unfortunately many lack error handling,
make device size logic errors or include complicated legacy performance hacks.

I wrote zram-swap because I couldn't find a modern replacement for the Ubuntu
`zram-config` package that was simple, handled failures without leaving swaps
half configured, didn't make common device sizing mistakes and kept user-facing
configuration straightforward and easy to understand.

Additionally underneath the systemd service wrapper the whole thing is written
in posix shell and only needs a shell, `modprobe`, `zramctl` and very basic
`awk` and `grep` calls to function.

### Installation and Usage

```bash
git clone https://github.com/foundObjects/zram-swap.git
cd zram-swap && sudo ./install.sh
```

The installer will start the zram-swap.service automatically after installation
and enable service start during each subsequent boot. The default allocation
creates an lz4 zram device that should use around half of physical memory when
completely full.

I chose lz4 as the default to give low spec machines (systems that often see
the greatest benefit from swap on zram) whatever performance edge I could.
While lzo-rle is quite fast on modern hardware a machine like a Raspberry Pi
2B appreciates every optimization advantage I can give it.

The default configuration using lz4 should work well for most people. lzo may
provide slightly better RAM utilization at a cost of slightly more expensive
decompression. zstd should provide better compression than lz\* and still be
moderately fast on most machines. On very modern kernels and reasonably fast
hardware the best overall choice is probably lzo-rle.

### Configuration

Edit `/etc/default/zram-swap` if you'd like to change compression algorithms or
swap allocation and then restart zram-swap with `systemctl restart zram-swap.service`.

A very simple configuration that's expected to use roughly 2GB RAM might look
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

This should run on pretty much any recent (4.0+? kernel) Linux system. If
anyone wants to test backward compatibility and let me know how compatible the
script is on older systems I'm interested but I don't have the legacy systems
or time to test exhaustively.

The core script should also be fully compatible with alternate init systems and
minimal systems using busybox.
