#!/usr/bin/env bash

set -ex

ROOT_FOLDER=${PWD}

mkdir -p new_versions

pushd new_versions || exit 666

grep "^mongodb" ${ROOT_FOLDER}/versions/keyval.properties|cut -d"=" -f2 > mongodb
grep "^rocksdb" ${ROOT_FOLDER}/versions/keyval.properties|cut -d"=" -f2 > rocksdb

popd