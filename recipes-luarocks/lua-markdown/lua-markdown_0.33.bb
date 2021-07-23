DESCRIPTION = "Markdown text-to-html markup system."
HOMEPAGE = "https://github.com/mpeterv/markdown"
LICENSE = "MIT&X11"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2ba696eb6f35a89e58608c6cc3504931"

SRC_URI = "git://github.com/mpeterv/markdown"
SRCREV = "0.33"

DEPENDS += ""
RDEPENDS_${PN} = "lua"

S = "${WORKDIR}/git"

inherit luarocks