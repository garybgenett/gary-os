# Distributed under the terms of the GNU General Public License v2

EAPI="7"

TEXLIVE_MODULE_CONTENTS="edmac eplain jadetex lollipop mltex psizzl startex texsis xmltex xmltexconfig aleph antomega lambda mxedruli omega omegaware otibet passivetex collection-formatsextra
"
TEXLIVE_MODULE_DOC_CONTENTS="edmac.doc eplain.doc jadetex.doc lollipop.doc mltex.doc psizzl.doc startex.doc texsis.doc aleph.doc antomega.doc mxedruli.doc omega.doc omegaware.doc otibet.doc xmltex.doc "
TEXLIVE_MODULE_SRC_CONTENTS="edmac.source eplain.source jadetex.source psizzl.source startex.source antomega.source otibet.source "
inherit  texlive-module
DESCRIPTION="TeXLive Additional formats"

LICENSE=" GPL-1 GPL-2 GPL-3 LPPL-1.3 public-domain TeX "
SLOT="0"
KEYWORDS="*"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2020
>=dev-texlive/texlive-latex-2020
dev-texlive/texlive-xetex
!app-text/jadetex
!dev-tex/xmltex
"
RDEPEND="${DEPEND} "
