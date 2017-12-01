#!/usr/bin/env bash

set -ex


ROOT_FOLDER=${PWD}

# installing needed packages
apt update
apt install -y curl

mkdir -p downloaded-src
pushd downloaded-src || exit 666


mkdir -p mongodb
cd mongodb || exit 666

mongodb_version=`cat ${ROOT_FOLDER}/versions/keyval.properties|grep "^mongodb"|cut -d "=" -f2`

if [ "$mongodb_version" != "" ]
then
	curl -o mongo-rocks-${mongodb_version}.tar.gz \
	  -L https://codeload.github.com/mongodb-partners/mongo-rocks/tar.gz/r${mongodb_version}
	curl -o mongodb-src-r${mongodb_version}.tar.gz \
	  -L https://fastdl.mongodb.org/src/mongodb-src-r${mongodb_version}.tar.gz
	curl -o mongo-tools-${mongodb_version}.tar.gz \
	  -L https://codeload.github.com/mongodb/mongo-tools/tar.gz/r${mongodb_version}
fi

rocksdb_version=`cat ${ROOT_FOLDER}/versions/keyval.properties|grep "^rocksdb"|cut -d "=" -f2`

if [ "$rocksdb_version" != "" ]
then
	curl -o rocksdb-${rocksdb_version}.tar.gz \
	  -L https://codeload.github.com/facebook/rocksdb/tar.gz/v${rocksdb_version}
fi
popd