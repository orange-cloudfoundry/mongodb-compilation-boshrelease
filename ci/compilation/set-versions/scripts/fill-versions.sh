#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

mkdir -p versions

pushd versions || exit 666

echo "mongodb=$(cat ${ROOT_FOLDER}/mongodb-src/metadata|jq -r '.version.ref')" >> keyval.properties
echo "rocksdb=$(cat ${ROOT_FOLDER}/rocksdb-src/metadata|jq -r '.version.ref')" >> keyval.properties
popd