# Maintainer: Citadel Project <citadel@example.com>
pkgname=citadel-dns
pkgver=3.1.2
pkgrel=1
pkgdesc="Fortified DNS Infrastructure with DNSCrypt-Proxy and CoreDNS"
arch=('any')
url="https://github.com/QguAr71/Cytadela"
license=('GPL3')
depends=(
    'bash'
    'curl'
    'wget'
    'git'
    'systemd'
    'nftables'
    'bind-tools'
    'jq'
    'openbsd-netcat'
    'dnscrypt-proxy'
    'coredns'
)
optdepends=(
    'dnsperf: Performance benchmarking'
    'bats: Testing framework'
    'shfmt: Shell script formatting'
    'shellcheck: Shell script analysis'
    'prometheus: Metrics collection'
    'grafana: Metrics visualization'
)
source=("$pkgname-$pkgver.tar.gz::https://github.com/QguAr71/Cytadela/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
    cd "$srcdir/Cytadela-$pkgver"

    # Install main files
    install -dm755 "$pkgdir/opt/cytadela"
    cp -r lib modules examples docs "$pkgdir/opt/cytadela/"
    install -m755 citadel.sh "$pkgdir/opt/cytadela/"
    install -m755 citadel_en.sh "$pkgdir/opt/cytadela/"

    # Install symlinks
    install -dm755 "$pkgdir/usr/bin"
    ln -sf /opt/cytadela/citadel.sh "$pkgdir/usr/bin/citadel"
    ln -sf /opt/cytadela/citadel_en.sh "$pkgdir/usr/bin/citadel-en"

    # Install systemd services (if any custom services are added)
    # install -Dm644 systemd/*.service "$pkgdir/usr/lib/systemd/system/"

    # Install documentation
    install -dm755 "$pkgdir/usr/share/doc/$pkgname"
    install -m644 README.md "$pkgdir/usr/share/doc/$pkgname/"
    install -m644 CHANGELOG.md "$pkgdir/usr/share/doc/$pkgname/"
    install -m644 docs/RELEASE-INSTRUCTIONS.md "$pkgdir/usr/share/doc/$pkgname/"

    # Install licenses
    install -dm755 "$pkgdir/usr/share/licenses/$pkgname"
    install -m644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/"

    # Create directories for runtime data
    install -dm755 "$pkgdir/etc/cytadela"
    install -dm755 "$pkgdir/var/lib/cytadela"

    # Set permissions
    chmod -R 755 "$pkgdir/opt/cytadela/modules"
}

# Optional: Add install script for post-install configuration
# install=citadel-dns.install
