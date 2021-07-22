#!/usr/bin/lua

-- Returns the full rockspec filename for package by globing
-- "${package}-*.rockspec" or 'nil' if it does not exist
function get_rockspec(package)
  local spec = io.popen(string.format('echo "%s"-*.rockspec', package)):read()
  if spec:find("*") then spec = nil end
  return spec
end

-- Transforms the lua package name to a usable BitBake package by
-- lowercaseing, prepending "lua-" if it does not start with "lua"
-- and replacing all underscores by dash
function pkg2bb_pkg(package)
  package = package:lower()
  if package:sub(1, 3) ~= "lua" then
    package = "lua-" .. package
  end
  package = package:gsub("_", "-")
  return package
end

-- inspect Package
function inspect_pkg(source)
  local result = { }
  if source.url:sub(-4):lower() == ".zip" then
    unpack = "unzip -fobq arch.zip"
  elseif source.url:sub(-4):lower() == ".git" then
    result["pkg_hash"] = string.format('SRCREV = "%s"', source.branch)
    result["pkg_dir"] = "git"
    result["pkg_lic"] = "license"
    return result
  else
    unpack = "tar zxf arch.zip"
  end
  local ret = io.popen(string.format([[
set -ex
mkdir -p TEMP &&
cd TEMP &&
curl -sL -o arch.zip '%s' &&
%s
sha256sum arch.zip
md5sum */LICEN* || md5sum */*.rockspec
cd .. && rm -rf TEMP/
]], source.url, unpack), "r")
  result["pkg_hash"] = string.format('SRC_URI[sha256sum] = "%s"',
				 ret:read():match("[^%s]*"))
  local lic = ret:read()
  local f = string.gmatch(lic, "[^%s]+")
  result["license_md5"] = f()
  f = string.gmatch(f(), "[^/]+")
  result["pkg_dir"] = f()
  result["pkg_lic"] = f()

  return result
end

function do_deps(deps)
  if not deps then return end
  print(string.format("Package '%s' depends on '%s'",
        package, table.concat(deps, " ")))

  for _, dep in next, deps do
    create_package(dep)
  end
end

-- creates a package
function create_package(package)
  print("Creating .bb file for " .. package)
  local spec = get_rockspec(package)
  if not spec then
    print(string.format("Downloading rockspec for '%s'....", package))
    os.execute(string.format("luarocks download --rockspec '%s'", package))
    spec = get_rockspec(package)
  else
    print(string.format("The rockspec file '%s' already exists", spec))
  end
  if not spec then
    print(string.format("Could not download rockspec for '%s'", package))
    return
  end

  -- read the rockspec
  dofile(spec)
  version = version:match("[^-]*")
  license = description.license:match("[^%s]*"):gsub("/", "&")
  local bb_package = pkg2bb_pkg(package)

  local deps = {} -- list of dependencies
  local bb_deps = {} -- list of bitbake dependencies

  dependencies = dependencies or { }
  for _, d in next, dependencies do
    -- remove version information from dependency
    d = d:match("[^%s]*")
    if (d ~= "lua") then
      table.insert(deps, d)
      table.insert(bb_deps, pkg2bb_pkg(d))
    end
  end

  local dir = "."
  if os.execute("test -d recipes-luarocks") then
    dir = string.format("recipes-luarocks/%s", bb_package)
    if os.execute(string.format("test -d '%s'", dir)) then
      print(string.format("Package '%s' already exists", dir))
      do_deps(deps)
      return
    end
    if not os.execute(string.format("mkdir -p '%s'", dir)) then
      return
    end
  end

  local result = inspect_pkg(source)
  local bbfile = string.format("%s/%s_%s.bb", dir, bb_package, version)

  print(string.format("Generating Bitbake file '%s'", bbfile))

  out = io.open(bbfile, "w")

  out:write(string.format([[
DESCRIPTION = "%s"
HOMEPAGE = "%s"
LICENSE = "%s"
LIC_FILES_CHKSUM = "file://%s;md5=%s"

SRC_URI = "%s"
%s

DEPENDS += "%s"
RDEPENDS_${PN} = "lua"

S = "${WORKDIR}/%s"

inherit luarocks
]],
description.summary, description.homepage,
license, result["pkg_lic"], result["license_md5"],
source.url, result["pkg_hash"],
table.concat(bb_deps, " "),
result["pkg_dir"]
))

  do_deps(deps)

end

create_package(arg[1])