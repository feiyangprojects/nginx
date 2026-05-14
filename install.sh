#!/usr/bin/env bash
set -e

apt update
apt install --yes \
    curl gettext git gzip jq python3 python3-packaging python3-requests tar xz-utils \
    autoconf automake cmake libtool musl-tools \
    debhelper dpkg dpkg-dev rpm

