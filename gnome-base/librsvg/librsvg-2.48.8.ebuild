# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"
GNOME2_EAUTORECONF="yes"
VALA_USE_DEPEND="vapigen"

inherit gnome2 multilib-minimal vala

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~arm64 ~sparc ~x86"

IUSE="debug +introspection tools vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.8.0[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.16.0[${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.38.0[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.1-r4:2[${MULTILIB_USEDEP}]
	>=x11-libs/gdk-pixbuf-2.30.7:2[introspection?,${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.10.8:= )
	tools? ( >=x11-libs/gtk+-3.10.0:3 )
"
DEPEND="${RDEPEND}
	>=virtual/rust-1.43.0[${MULTILIB_USEDEP}]
	dev-libs/gobject-introspection-common
	>=dev-util/gtk-doc-am-1.13
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
	vala? ( $(vala_depend) )
"
# >=gtk-doc-am-1.13, gobject-introspection-common, vala-common needed by eautoreconf

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

multilib_src_configure() {
	local myconf=()

	# -Bsymbolic is not supported by the Darwin toolchain
	if [[ ${CHOST} == *-darwin* ]]; then
		myconf+=( --disable-Bsymbolic )
	fi

	# --disable-tools even when USE=tools; the tools/ subdirectory is useful
	# only for librsvg developers
	ECONF_SOURCE=${S} \
	cross_compiling=yes \
	gnome2_src_configure \
		--disable-static \
		--disable-tools \
		$(use_enable debug) \
		$(use_enable tools) \
		$(multilib_native_use_enable introspection) \
		$(multilib_native_use_enable vala) \
		--enable-pixbuf-loader \
		--disable-gtk-doc \
		"${myconf[@]}"

	if multilib_is_native_abi; then
		ln -s "${S}"/doc/html doc/html || die
	fi
}

multilib_src_compile() {
	# causes segfault if set, see bug #411765
	unset __GL_NO_DSO_FINALIZER
	gnome2_src_compile
}

multilib_src_install() {
	gnome2_src_install
}

pkg_postinst() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	multilib_foreach_abi gnome2_pkg_postinst
}

pkg_postrm() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	multilib_foreach_abi gnome2_pkg_postrm
}