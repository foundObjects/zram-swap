# Maintainer: Arglebargle < arglebargle DASH aur AT arglebargle DOT dev >
pkgname=zram-swap-git
_pkgname=zram-swap
pkgver=02.r1.g867269f
pkgrel=1
pkgdesc="A simple zram swap service for modern systemd Linux"
arch=('any')
url="https://github.com/foundObjects/zram-swap.git"
license=('MIT')
depends=('systemd' 'bash')
backup=('etc/default/zram-swap')
source=('git+https://github.com/foundObjects/zram-swap.git')
sha512sums=('SKIP')

pkgver() {
  cd ${_pkgname}
  git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

prepare() {
  cd ${_pkgname}
  sed -i 's/local\/s//g' ./service/zram-swap.service
}

package() {
  provides=("$_pkgname")
  cd ${_pkgname}
  install -Dm0644 "${srcdir}/${_pkgname}/service/zram-swap.service" "${pkgdir}/usr/lib/systemd/system/zram-swap.service"
  install -Dm0644 "${srcdir}/${_pkgname}/service/zram-swap.config" "${pkgdir}/etc/default/zram-swap"
  install -Dm0755 "${srcdir}/${_pkgname}/zram-swap.sh" "${pkgdir}/usr/bin/zram-swap.sh"
}

