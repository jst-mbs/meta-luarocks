SUMMARY = "LuaRocks is the package manager for the Lua programming language"
HOMEPAGE = "https://github.com/luarocks/luarocks"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=5a26c606953a58c545aa194713fcdfc8"

DEPENDS += "\
            curl-native \
            lua-native \
            openssl-native \
            unzip-native \
            lua \
            "

SRC_URI = "git://github.com/luarocks/luarocks;protocol=https \
           file://0001-luarocks-native-avoid-using-host-libs-and-includes.patch \
           "
SRCREV = "b2a271cc9798e56c443ace6e0a50f13148bf4bb2"

S = "${WORKDIR}/git"

do_configure() {
    ./configure --prefix=${prefix}
}

do_compile() {
    oe_runmake LUA_INCDIR="${RECIPE_SYSROOT}/usr/include"
}

do_install() {
    oe_runmake install DESTDIR=${D}
}

FILES:${PN} += "${sysconfdir} ${bindir} ${datadir} ${libdir}"

inherit native
