# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools multilib-minimal

PATCHES=( "${FILESDIR}/${PN}-1.0.2-qtbindir.patch" )

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/strukturag/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/strukturag/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Open h.265 video codec implementation"
HOMEPAGE="https://github.com/strukturag/libde265"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="debug qt5 static-libs cpu_flags_x86_sse"

DEPEND="
	media-libs/libsdl
	virtual/ffmpeg
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
"
RDEPEND="${DEPEND}"

src_prepare() {
	default

	eautoreconf

	# without this, headers would be missing and make would fail
	multilib_copy_sources
}

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable cpu_flags_x86_sse sse)
		$(use_enable static-libs static)
		$(use_enable debug log-info)
		$(use_enable debug log-debug)
		$(use_enable debug log-trace)
		$(use_enable qt5 dec265)
		$(use_enable qt5 sherlock265)
		--enable-log-error
	)
	econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	find "${ED}" -name '*.la' -delete || die
	if ! use static-libs ; then
		find "${ED}" -name "*.a" -delete || die
	fi
}
