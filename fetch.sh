#!/bin/sh -e

# Use it with `anitya_fetch PROJECTID PROJECTNAME https://scm.example.org/user/project/refs/tags/vPROJECTNAME_VERSION TAR_TRANSFORM`
function anitya_fetch() {
    case "$3" in
        *.bz2) FORMAT='j' ;;
        *.gz) FORMAT='z' ;;
        *.xz) FORMAT='J' ;;
        *) echo -e 'Unrecognized compressed archive format.' && exit 1 ;;
    esac

    PROJECT_NAME="$(echo "$2" | tr '[:lower:]' '[:upper:]')"
    export "${PROJECT_NAME}_VERSION=$(curl "https://release-monitoring.org/api/v2/versions/?project_id=$1" | jq -r '.latest_version')"
    curl -L "$(echo "$3" | envsubst)" | tar -x$FORMAT --transform "$4"
}

mkdir -p workdir
cd workdir

mkdir -p lib
cd lib
anitya_fetch 1783 libxml2 'https://gitlab.gnome.org/GNOME/libxml2/-/archive/v$LIBXML2_VERSION/libxml2-v$LIBXML2_VERSION.tar.gz' 's#^libxml2-[^/]*#libxml2#'
anitya_fetch 12102 libressl 'https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$LIBRESSL_VERSION.tar.gz' 's#^libressl-[^/]*#libressl#'
anitya_fetch 13301 libxslt 'https://gitlab.gnome.org/GNOME/libxslt/-/archive/v$LIBXSLT_VERSION/libxslt-v$LIBXSLT_VERSION.tar.gz' 's#^libxslt-[^/]*#libxslt#'
anitya_fetch 5832 pcre2 'https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$PCRE2_VERSION/pcre2-$PCRE2_VERSION.tar.gz' 's#^pcre2-[^/]*#pcre2#'
anitya_fetch 5303 zlib 'https://github.com/madler/zlib/archive/refs/tags/v$ZLIB_VERSION.tar.gz' 's#^zlib-[^/]*#zlib#'
cd ..

mkdir -p mod
cd mod
# Use git HEAD for headers-more-nginx-module, nginx-dav-ext-module and ngx_brotli due to no recent release
git clone --depth=1 --recurse-submodules https://github.com/openresty/headers-more-nginx-module.git
git clone --depth=1 --recurse-submodules https://github.com/arut/nginx-dav-ext-module.git
git clone --depth=1 --recurse-submodules https://github.com/google/ngx_brotli.git
git clone --depth=1 --recurse-submodules https://github.com/aperezdc/ngx-fancyindex.git
anitya_fetch 212650 njs 'https://github.com/nginx/njs/archive/refs/tags/$NJS_VERSION.tar.gz' 's#^njs-[^/]*#njs#'
cd ..

anitya_fetch 5413 nginx 'https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz' 's#^nginx-[^/]*#core#'

printenv | grep -E '_VERSION=' > ver
if [ -n "$GITHUB_OUTPUT" ]; then
    printenv | grep -E '_VERSION=' > "$GITHUB_OUTPUT"
fi
cd ..
