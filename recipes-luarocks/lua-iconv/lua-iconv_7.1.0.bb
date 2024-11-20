SUMMARY = "Lua binding to the iconv"
DESCRIPTION = " Lua binding to the POSIX 'iconv' library, which converts a sequence of characters from one codeset into a sequence of corresponding characters in another codeset. "
HOMEPAGE = "https://github.com/lunarmodules/lua-iconv"
LICENSE = "MIT&X11"
LIC_FILES_CHKSUM = "file://COPYING;md5=2703ed4b4fdac99f8e3092bb2f6b7d3e"

SRC_URI = "git://github.com/lunarmodules/lua-iconv.git;branch=master;protocol=https"
SRCREV = "v7.1.0"
S = "${WORKDIR}/git"

# If the QA error about gnu-hash shows up, try uncommenting the following line
# LUAROCKS_EXTRA_CC = "${LDFLAGS}"

inherit luarocks
