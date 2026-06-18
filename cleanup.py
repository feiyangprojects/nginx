#!/usr/bin/python3
import os
from packaging.version import Version
import requests

session = requests.Session()
session.headers.update({"Authorization": "token " + os.environ["CLOUDSMITH_API_KEY"]})

checked_packages = {}
packages = session.get(
    "https://api.cloudsmith.io/v1/packages/"
    + os.environ["CLOUDSMITH_NAMESPACE"]
    + "/"
    + os.environ["CLOUDSMITH_REPOSITORY"]
    + "?page_size=65535"
).json()

for package in packages:
    package_identifier = (
        package["identifiers"]["distro_version"]
        + "/"
        + package["identifiers"]["name"]
        + "/"
        + package["identifiers"]["architecture"]
    )

    try:
        package_version = Version(package["version"])

        if (
            package_identifier in checked_packages
            and checked_packages[package_identifier] > package_version
        ):
            session.delete(
                "https://api.cloudsmith.io/v1/packages/"
                + os.environ["CLOUDSMITH_NAMESPACE"]
                + "/"
                + os.environ["CLOUDSMITH_REPOSITORY"]
                + "/"
                + package["slug_perm"]
            )
            print(
                "Deleted old version "
                + package["version"]
                + "of package "
                + package_identifier
            )
        else:
            checked_packages[package_identifier] = package_version
    except:
        pass
