#!/bin/sh -e
cd workdir
NGINX_VERSION="$(cat ver/NGINX)"
cd deb
sed -i "s/__NGINX_VERSION__/$NGINX_VERSION/" DEBIAN/control
mkdir -p etc/nginx lib/systemd/system usr/sbin var/lib/nginx var/log/nginx
cp ../../conf/nginx.service lib/systemd/system
cp ../core/conf/* etc/nginx
cp ../core/objs/nginx usr/sbin
find -maxdepth 1 ! -name '.' ! -name 'DEBIAN' -exec chown -R root:root {} \;
find -type d ! -name 'DEBIAN' -exec chmod 755 {} \;
chmod 750 var/lib/nginx var/log/nginx
chmod 755 usr/sbin/nginx
dpkg-deb --build . ../../dist/nginx.deb
cd ..

cd rpm
sed -i "s/__NGINX_VERSION__/$NGINX_VERSION/" package.spec
cp ../../conf/* .
cp ../core/conf/* .
cp ../core/objs/nginx .
rpmbuild \
    -bb \
    --define "_sourcedir $PWD" \
    --define "_rpmdir $PWD/../../dist" \
    --define '_rpmfilename %%{NAME}.rpm' \
    --define '__brp_strip_static_archive /bin/true' \
    --define '__brp_remove_la_files /bin/true' \
    package.spec
cd ..
cd ..