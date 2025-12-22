#!/bin/sh -e
cd workdir
. ver

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
dpkg-deb --build . "../../dist/nginx-$NGINX_VERSION.deb"
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
    --define '_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm' \
    --define '__brp_strip_static_archive /bin/true' \
    --define '__brp_remove_la_files /bin/true' \
    package.spec
cd ..

cd ..

if [ -n "$CLOUDSMITH_API_KEY" ]; then
    cd dist

    DEB="$(find -name '*.deb' -exec basename {} \;)"
    DEB_IDENTIFIER="$(curl \
        --header "Content-Sha256: $(sha256sum "$DEB" | cut -d ' ' -f 1)" \
        --upload-file "$DEB" \
        "https://$CLOUDSMITH_USERNAME:$CLOUDSMITH_API_KEY@upload.cloudsmith.io/$CLOUDSMITH_REPOSITORY/$DEB" | jq -r '.identifier')"
    curl \
        --request POST \
        --header "Content-Type: application/json"  \
        --data "{\"distribution\":\"otherdeb/any-version\",\"package_file\":\"$DEB_IDENTIFIER\"}" \
        "https://$CLOUDSMITH_USERNAME:$CLOUDSMITH_API_KEY@api.cloudsmith.io/v1/packages/$CLOUDSMITH_REPOSITORY/upload/deb/"
    RPM="$(find -name '*.rpm' -exec basename {} \;)"
    RPM_IDENTIFIER="$(curl \
        --header "Content-Sha256: $(sha256sum "$RPM" | cut -d ' ' -f 1)" \
        --upload-file "$RPM" \
        "https://$CLOUDSMITH_USERNAME:$CLOUDSMITH_API_KEY@upload.cloudsmith.io/$CLOUDSMITH_REPOSITORY/$RPM" | jq -r '.identifier')"
    curl \
        --request POST \
        --header "Content-Type: application/json"  \
        --data "{\"distribution\":\"otherrpm/any-version\",\"package_file\":\"$RPM_IDENTIFIER\"}" \
        "https://$CLOUDSMITH_USERNAME:$CLOUDSMITH_API_KEY@api.cloudsmith.io/v1/packages/$CLOUDSMITH_REPOSITORY/upload/rpm/"

    cd ..
fi
