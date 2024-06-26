#!/bin/sh -e
ANITYA_API_VERSIONS="https://release-monitoring.org/api/v2/versions/"

mkdir -p workdir
cd workdir
mkdir -p lib
cd lib
LIBXML2_VERSION="$(curl "$ANITYA_API_VERSIONS?project_id=1783" | jq -r '.latest_version')"
curl "https://gitlab.gnome.org/GNOME/libxml2/-/archive/v$LIBXML2_VERSION/libxml2-v$LIBXML2_VERSION.tar.gz" | tar xz --one-top-level=libxml2 --strip-components=1
LIBXSLT_VERSION="$(curl "$ANITYA_API_VERSIONS?project_id=13301" | jq -r '.latest_version')"
curl "https://gitlab.gnome.org/GNOME/libxslt/-/archive/v$LIBXSLT_VERSION/libxslt-v$LIBXSLT_VERSION.tar.gz" | tar xz --transform 's#^libxslt-[^/]*#libxslt#'

curl "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$(curl "$ANITYA_API_VERSIONS?project_id=12102" | jq -r '.latest_version').tar.gz" | tar xz --one-top-level=libressl --strip-components=1
curl --location "https://github.com/PCRE2Project/pcre2/releases/latest/download/pcre2-$(curl "$ANITYA_API_VERSIONS?project_id=5832" | jq -r '.latest_version').tar.gz" | tar xz --one-top-level=pcre2 --strip-components=1
curl "https://zlib.net/zlib-$(curl "$ANITYA_API_VERSIONS?project_id=5303" | jq -r '.latest_version').tar.gz" | tar xz --one-top-level=zlib --strip-components=1
cd ..

mkdir -p mod
cd mod
# Use git HEAD for headers-more-nginx-module, nginx-dav-ext-module and ngx_brotli due to no recent release
git clone --depth=1 https://github.com/openresty/headers-more-nginx-module.git
git clone --depth=1 https://github.com/arut/nginx-dav-ext-module.git
git clone --depth=1 --recurse-submodules https://github.com/google/ngx_brotli.git
git clone --depth=1 https://github.com/aperezdc/ngx-fancyindex.git
curl --location "https://github.com/nginx/njs/archive/refs/tags/$(curl "$ANITYA_API_VERSIONS?project_id=212650" | jq -r '.latest_version').tar.gz" | tar xz --one-top-level=njs --strip-components=1
cd ..

curl "https://nginx.org/download/nginx-$(curl "$ANITYA_API_VERSIONS?project_id=5413" | jq -r '.latest_version').tar.gz" | tar xz --one-top-level=core --strip-components=1
cd ..
