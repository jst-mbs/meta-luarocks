SUMMARY = "A cross-platform terminal ui library based on Lua"
DESCRIPTION = "This framework originated from the requirements of graphical menu configuration in [xmake](https://github.com/tboox/xmake). Similar to the kernel kernel's menuconf to configure the compilation parameters, so using curses and lua to implement a cross-platform character terminal ui library."
HOMEPAGE = "https://github.com/tboox/ltui"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=0b737be2e435b3c9610f7db199938011"

SRC_URI = "git://github.com/tboox/ltui;nobranch=1;protocol=https"
SRCREV = "184fb85b37fd086491a7f91698d2e781bd0ca977"

S = "${WORKDIR}/git"

inherit luarocks
