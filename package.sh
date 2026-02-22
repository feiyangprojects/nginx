#!/usr/bin/env bash
set -e

cd workdir
. ver

cd deb
sed -Ei "s/(nginx \()[0-9\.]+/\1$NGINX_VERSION/" debian/changelog
dpkg-buildpackage -b
cd ..
mv *.deb ../dist
cd rpm
sed -Ei "s/(Version:        )[0-9\.]+/\1$NGINX_VERSION/" package.spec
cp ../../conf/* .
rpmbuild \
    -bb \
    --define "_builddir $PWD/../core" \
    --define "_sourcedir $PWD" \
    --define "_rpmdir $PWD/../../dist" \
    --define '_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm' \
    package.spec
cd ..

cd ..

if [ -n "$CLOUDSMITH_API_KEY" ]; then
    cd dist

    for type in deb rpm; do
        PACKAGE="$(find -name "*.$type" -exec basename {} \;)"
        PACKAGE_IDENTIFIER="$(curl \
            --header "Content-Sha256: $(sha256sum "$PACKAGE" | cut -d ' ' -f 1)" \
            --upload-file "$PACKAGE" \
            "https://$CLOUDSMITH_USERNAME:$CLOUDSMITH_API_KEY@upload.cloudsmith.io/$CLOUDSMITH_REPOSITORY/$PACKAGE" | jq -r '.identifier')"
        curl \
            --request POST \
            --header "Content-Type: application/json"  \
            --data "{\"distribution\":\"other$type/any-version\",\"package_file\":\"$PACKAGE_IDENTIFIER\"}" \
            "https://$CLOUDSMITH_USERNAME:$CLOUDSMITH_API_KEY@api.cloudsmith.io/v1/packages/$CLOUDSMITH_REPOSITORY/upload/$type/"
    done

    cd ..
fi
