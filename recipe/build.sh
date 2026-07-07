#! /usr/bin/bash
set -e

# Upstream's ./configure fails if a directory it tries to create already exists
sed -i 's/mkdir /mkdir -p /g' makefile.in
# Use the correct OS-version of strip for cross-compilation
sed -i "s|strip |$STRIP |g" makefile.in
# Avoid $BUILD_PREFIX leaking into LDFLAGS via $FLDFLAGS -- it hardcodes
# build-time tool paths that won't exist at install time
sed -i 's/$LDFLAGS $CONF_LDFLAGS $FLDFLAGS/$LDFLAGS $CONF_LDFLAGS -lgfortran/g' configure

cp "${BUILD_PREFIX}/share/gnuconfig/config.sub" "${BUILD_PREFIX}/share/gnuconfig/config.guess" .
./configure --prefix="${PREFIX}"

make
make install

# Upstream's fcc wrapper script hardcodes $BUILD_PREFIX; switch it to $PREFIX
# so conda-build's prefix-replacement patches it like everything else.
sed -i "s|${BUILD_PREFIX}|${PREFIX}|g" "${PREFIX}/bin/fcc"

# conda expects lib/, not lib64/
if [ -d "${PREFIX}/lib64" ]; then
    mv "${PREFIX}/lib64/libooptools.a" "${PREFIX}/lib/libooptools.a"
fi
