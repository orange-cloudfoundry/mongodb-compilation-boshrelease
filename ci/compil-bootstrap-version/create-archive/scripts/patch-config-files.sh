#!/usr/bin/env sh

set -ex

ROOT_FOLDER=${PWD}

cp -rp mongodb-compilation-bosh-release-patched/. to-upload/

MONGO_VERSION=$(grep "^mongodb" versions/keyval.properties|cut -d"=" -f2)

if [ "${STEMCELL_TYPE}" == "" ]
then
	STEMCELL_TYPE="ubuntu"
fi

# removing previous blobs

sed -i -e "/mongodb\/mongodb-${STEMCELL_TYPE}-x86_64-${MONGO_VERSION}.tar.gz:/,/sha:/d" to-upload/config/blobs.yml


# Adding the last compiled one
sed -e "/mongodb\/mongodb-${STEMCELL_TYPE}-x86_64-${MONGO_VERSION}.tar.gz:/,/sha:/!d" \
	mongodb-compilation-bosh-release-archive/config/blobs.yml >> to-upload/config/blobs.yml

