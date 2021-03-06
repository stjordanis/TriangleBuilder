# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Triangle"
version = v"1.6.0"

# Collection of sources required to build triangle
#
# Please be aware that triunsuitable.c is not part of the original Triangle distribution.
# It provides the possibility to pass a cfunction created in Julia as  user refinement callback.
# For this reason at least triunsiutable.c must be downloaded from Triangulate.jl repo.
#
sources = [
    "https://github.com/JuliaGeometry/Triangulate.jl.git" =>
    "b2ffb23ca7d89c567fd31367882bd216757cdb9c",
#    "e7b1237f64ac1ad3b3d205c5b53ad0928b17c631", @binary_builder-0.1

]


# Bash recipe for building across all platforms

script = raw"""
cd $WORKSPACE/srcdir
cd Triangulate.jl/deps/src
if [[ ${target} == *-mingw32 ]]; then     libdir="bin"; else     libdir="lib"; fi
mkdir ${prefix}/${libdir}
sed -e "s/  exit/extern void error_exit(int); error_exit/g" triangle/triangle.c > triangle_patched.c
$CC -Itriangle -DREAL=double -DTRILIBRARY -O3 -fPIC -DNDEBUG -DNO_TIMER -DEXTERNAL_TEST $LDFLAGS --shared -o ${prefix}/${libdir}/libtriangle.${dlext} triangle_patched.c triwrap.c
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
# platforms = [
#     Linux(:i686, libc=:glibc),
#     Linux(:x86_64, libc=:glibc),
#     Linux(:aarch64, libc=:glibc),
#     Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
#     Linux(:powerpc64le, libc=:glibc),
#     Linux(:i686, libc=:musl),
#     Linux(:x86_64, libc=:musl),
#     Linux(:aarch64, libc=:musl),
#     Linux(:armv7l, libc=:musl, call_abi=:eabihf),
#     MacOS(:x86_64),
#     FreeBSD(:x86_64),
#     Windows(:i686),
#     Windows(:x86_64)
# ]

platforms = BinaryBuilder.supported_platforms()

# The products that we will ensure are always built
products(prefix) = [  LibraryProduct(prefix,"libtriangle", :libtriangle) ]

# Dependencies that must be installed before this package can be built
dependencies = []

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

