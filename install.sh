#!/usr/bin/env bash
set -e

apt update
apt install --yes \
    curl gettext git gzip jq tar xz-utils \
    autoconf automake cmake libtool musl-tools \
    debhelper dpkg dpkg-dev rpm
