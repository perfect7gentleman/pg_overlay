# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
# Python is used during build for some scripted source files generation (and twisted tests)
PYTHON_COMPAT=( python2_7 )

inherit gnome2 python-any-r1 autotools git-r3

DESCRIPTION="A XMPP connection manager, handles single and multi user chats and voice calls"
HOMEPAGE="https://telepathy.freedesktop.org/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/TelepathyIM/${PN}.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="gnutls +jingle libressl plugins test"
RESTRICT="!test? ( test )"

# Prevent false positives due nested configure
QA_CONFIGURE_OPTIONS=".*"

# FIXME: missing sasl-2 for tests ? (automagic)
# missing libiphb for wocky ?
# x11-libs/gtksourceview:3.0 needed by telepathy-gabble-xmpp-console, bug #495184
# Keep in mind some deps or higher minimum versions are in ext/wocky/configure.ac
RDEPEND="
	>=dev-libs/glib-2.44:2
	>=sys-apps/dbus-1.1.0
	>=dev-libs/dbus-glib-0.82
	>=net-libs/telepathy-glib-0.19.9

	dev-libs/libxml2
	dev-db/sqlite:3

	gnutls? ( >=net-libs/gnutls-2.10.2 )
	!gnutls? (
		libressl? ( dev-libs/libressl:0= )
		!libressl? ( >=dev-libs/openssl-0.9.8g:0=[-bindist] )
	)
	jingle? (
		>=net-libs/libsoup-2.42
		>=net-libs/libnice-0.0.11 )
	plugins? ( x11-libs/gtksourceview:3.0[introspection] )

	!<net-im/telepathy-mission-control-5.5.0
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	dev-util/glib-utils
	>=dev-util/gtk-doc-am-1.17
	dev-libs/libxslt
	virtual/pkgconfig
"
# Twisted tests fail if bad ipv6 setup, upstream bug #30565
# Random twisted tests fail with org.freedesktop.DBus.Error.NoReply for some reason
# pygobject:2 is needed by twisted-17 for gtk2reactor usage by gabble
#test? (
#	dev-python/pygobject:2
#	>=dev-python/twisted-16.0.0
#)

PATCHES=(
	"${FILESDIR}"/${PN}-0.18.4-build-fix-no-jingle.patch # build with USE=-jingle, bug #523230
)

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-coding-style-checks \
		--disable-static \
		--disable-Werror \
		--enable-file-transfer \
		$(use_enable jingle voip) \
		$(use_enable jingle google-relay) \
		$(use_enable plugins) \
		--with-tls=$(usex gnutls gnutls openssl) \
		--enable-submodules
}

src_test() {
	# This runs only C tests (see tests/README):
	emake -C tests check-TESTS
}
