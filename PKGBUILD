# -*- shell-script -*-
# Maintainer: Eric Schulte <eric.schulte@gmx.com>
# Contributor: Eric Schulte <eric.schulte@gmx.com>
pkgname=dissemination
pkgver=0.1
pkgrel=1
pkgdesc="working out a protocol for distributed information dissemination"
arch=('any')
url="http://gitweb.adaptive.cs.unm.edu/dissemination.git"
license=('GPL3')
makedepends=('bash' 'gzip' 'gnupg' 'sed' 'grep' 'coreutils' 'jshon' 'gnu-netcat')
source=(http://cs.unm.edu/~eschulte/data/dissemination.tar.gz)
md5sums=('placeholder')

build() {
  cd "$srcdir/$pkgname/"
}

package() {
  cd "$srcdir/$pkgname"
  make DESTDIR=$pkgdir install
} 
