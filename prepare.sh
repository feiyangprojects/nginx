#!/bin/sh -e
apk add --no-cache \
    curl gettext git gzip jq tar xz \
    autoconf automake build-base cmake libtool \
    dpkg rpm
