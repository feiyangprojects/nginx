#!/usr/bin/env bash
set -e

export CC='musl-gcc'

function cmake_build_and_install() {
    if [ -z "$CMAKE_WORKDIR" ]; then
        CMAKE_WORKDIR='build'
    fi
    mkdir -p "$CMAKE_WORKDIR"
    cd "$CMAKE_WORKDIR"
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-O2 -Wall -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -fstack-protector-strong -funwind-tables -fasynchronous-unwind-tables -fstack-clash-protection -Werror=return-type -flto=auto -g -fPIC -D_GNU_SOURCE" \
    -DCMAKE_CXX_FLAGS="-O2 -Wall -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -fstack-protector-strong -funwind-tables -fasynchronous-unwind-tables -fstack-clash-protection -Werror=return-type -flto=auto -g -fPIC -D_GNU_SOURCE" \
    $@ ..
    CMAKE_BUILD_ARGS=()
    if [ -n "$CMAKE_BUILD_TARGET" ]; then
        CMAKE_BUILD_ARGS+=('--target' "$CMAKE_BUILD_TARGET")
    fi
    cmake \
    --build . \
    ${CMAKE_BUILD_ARGS[@]} \
    --config Release
    cmake --install . || true
    cd ..
}

cd workdir

cd lib
cd libxml2
cmake_build_and_install \
    -DBUILD_SHARED_LIBS=OFF \
    -DLIBXML2_WITH_PROGRAMS=OFF \
    -DLIBXML2_WITH_TESTS=OFF \
    -DLIBXML2_WITH_PYTHON=OFF
cd ..
cd libxslt
cmake_build_and_install \
    -DBUILD_SHARED_LIBS=OFF \
    -DLIBXSLT_WITH_TESTS=OFF \
    -DLIBXSLT_WITH_PYTHON=OFF
cd ..
cd ..

cd mod
cd ngx_brotli/deps/brotli
CMAKE_WORKDIR=out CMAKE_BUILD_TARGET=brotlienc cmake_build_and_install \
    -DBUILD_SHARED_LIBS=OFF \
    -DBROTLI_BUILD_TOOLS=OFF
cd ../../..
cd ..

cd core
./configure \
    --prefix=/usr/ \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/nginx.lock \
    --http-client-body-temp-path=/var/lib/nginx/tmp/ \
    --http-proxy-temp-path=/var/lib/nginx/proxy/ \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi/ \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi/ \
    --http-scgi-temp-path=/var/lib/nginx/scgi/ \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-pcre=../lib/pcre2 \
    --with-zlib=../lib/zlib \
    --with-openssl=../lib/libressl \
    --add-module=../mod/headers-more-nginx-module \
    --add-module=../mod/nginx-dav-ext-module \
    --add-module=../mod/ngx_brotli \
    --add-module=../mod/ngx-fancyindex \
    --add-module=../mod/njs/nginx \
    --with-cc-opt="-O2 -Wall -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -fstack-protector-strong -funwind-tables -fasynchronous-unwind-tables -fstack-clash-protection -Werror=return-type -flto=auto -g -fPIC -D_GNU_SOURCE" \
    --with-ld-opt="-Wl,-z,relro,-z,now -pie -s -static"
make
cd ..

cd ..
