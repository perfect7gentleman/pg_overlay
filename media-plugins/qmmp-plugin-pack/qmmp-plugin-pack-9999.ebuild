# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake subversion

DESCRIPTION="A set of extra plugins for Qmmp"
HOMEPAGE="http://qmmp.ylsoftware.com/"

ESVN_REPO_URI="svn://svn.code.sf.net/p/qmmp-dev/code/trunk/${PN}/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	media-libs/taglib
	=media-sound/qmmp-$(ver_cut 1-2)*
	
"
DEPEND="${RDEPEND}
	dev-lang/yasm
	dev-qt/linguist-tools:5
"

src_prepare() {
	mycmakeargs=(
		-DUSE_FFVIDEO=0
		-DUSE_GOOM=0
		-DUSE_SRC=0
		-DUSE_XMP=0
		-DUSE_YTB=0
	)

	cmake_src_prepare
	}
