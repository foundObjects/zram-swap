# zram-swap
A simple zram swap script for modern systemd Linux

https://github.com/foundObjects/zram-swap

### Why?

I wrote zram-swap because I couldn't find a simple modern replacement for the Ubuntu
`zram-config` package that included basic error handling, didn't make device sizing
mistakes and kept user-facing configuration straightforward and easy to understand.

### Installation and Usage

*Arch Linux:*

Install from the AUR: `paru -S zram-swap-git`

or directly from GitHub:

```sh
mkdir zram-swap-git && cd zram-swap-git
wget https://raw.githubusercontent.com/foundObjects/zram-swap/arch-packaging/PKGBUILD
makepkg -Cci
```

You'll need to start and enable `zram-swap.service` after installation on Arch.
Make any configuration changes to `/etc/default/zram-swap` first if desired, see below for details.

*Others:*

```sh
git clone https://github.com/foundObjects/zram-swap.git
cd zram-swap && sudo ./install.sh
```

The install script starts the zram-swap.service automatically after installation
and enables the systemd service during boot. The default allocation creates an lz4
zram device that should use around half of physical memory when completely full.

I chose lz4 as the default to give low spec machines (systems that often see
the greatest benefit from swap on zram) every performance edge I could.
While lzo-rle is quite fast on modern high-performance hardware a machine like a
Raspberry Pi or a low spec laptop appreciates every speed advantage I can give it.

### Configuration

Edit `/etc/default/zram-swap` if you'd like to change the compression algorithm or
swap allocation and then restart zram-swap with `systemctl restart zram-swap.service`.
The configuration file is heavily commented and self-documenting.

A very simple configuration that's expected to use roughly 2GB RAM might look
something like:

```sh
# override fractional calculations and specify a fixed swap size
_zram_fixedsize="6G"

# compression algorithm to employ (lzo, lz4, zstd, lzo-rle)
_zram_algorithm="lzo-rle"
```

Remember that the ZRAM device size references uncompressed data, real memory
utilization should be ~2-3x smaller than the zram device size due to compression.

If you run `install.sh` in a automatic script, like ansible, use `SET_CONFIG_UPDATE=[(I)nstall, (K)eep] ./install.sh` to skip the interactive-prompt.

#### A quick note RE: compression algorithms:

The default configuration using lz4 should work well for most people. lzo may
provide slightly better RAM utilization at a cost of slightly more expensive
decompression. zstd should provide better compression than lz\* and still be
moderately fast on most machines. On very modern kernels and reasonably fast
hardware the most balanced choice is probably lzo-rle. On low spec machines
(ARM SBCs, ARM laptops, thin clients, etc) you'll probably want to stick with
lz4.

### Debugging

To view a script debug trace either start zram-swap.sh with `zram-swap.sh -x (start|stop)`
or uncomment the debug flag in `/etc/default/zram-swap`:

```sh
# setting _zram_swap_debugging to any non-zero value enables debugging
# default: undefined
_zram_swap_debugging="beep boop"
```

### Compatibility

Tested on Linux 4.4 through Linux 5.14.

Requirements are minimal; Underneath the systemd service wrapper the swap setup
script needs only a posix shell, `modprobe`, `zramctl` and very basic `awk` and
`grep` support to function. It should work in pretty much any modern Linux
environment.
