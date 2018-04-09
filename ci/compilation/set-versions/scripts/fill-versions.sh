#!/usr/bin/env sh

set -ex

ROOT_FOLDER=${PWD}

mkdir -p output

cd output || exit 666

echo "mongodb=$(cat ${ROOT_FOLDER}/mongodb-src/metadata|jq -r '.version.ref')" >> keyval.properties
echo "rocksdb=$(cat ${ROOT_FOLDER}/rocksdb-src/metadata|jq -r '.version.ref')" >> keyval.properties

cd ${ROOT_FOLDER}