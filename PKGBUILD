# -*- shell-script -*-
# Maintainer: Eric Schulte <eric.schulte@gmx.com>
# Contributor: Eric Schulte <eric.schulte@gmx.com>
pkgname=dissemination-git
pkgver=0.1
pkgrel=1
pkgdesc="working out a protocol for distributed information dissemination"
arch=('any')
url="http://gitweb.adaptive.cs.unm.edu/dissemination.git"
license=('GPL3')
makedepends=('bash' 'gzip' 'gnupg' 'sed' 'grep' 'coreutils' 'jshon' 'gnu-netcat')
provides=('dissemination')

_gitroot="git@adaptive:dissemination"
_gitname="dissemination"

build() {
  cd "$srcdir"
  msg "Connecting to GIT server...."

  ## Git checkout
  if [ -d $_gitname ] ; then
    pushd $_gitname && git pull origin && popd
  else
    git clone $_gitroot $_gitname
  fi
  msg "Checkout completed"
}

package() {
  cd "$srcdir/"${_gitname}
  make DESTDIR=$pkgdir install
}
