#!/usr/bin/env bash 

set -ex

# Installing needed packages
apt update
apt install -y curl jq

# last compiled and validated releases
last_mongodb_version=$(cat mongodb-version/version)
last_rocksdb_version=$(cat rocksdb-version/version)

# retrieve last provided versions on products repositories 
mongodb_last_stable=$(mongodb-compilation-bosh-release/ci/compilation/check-versions/scripts/get_last_mongo_version.pl)
rocksdb_last_stable=$(mongodb-compilation-bosh-release/ci/compilation/check-versions/scripts/get_last_rocksdb_version.pl)

# force mongodb version for tests
# DONT FORGET TO REMOVE IT
mongodb_last_stable=3.4.10
rocksdb_last_stable=5.8.6

[ "$mongodb_last_stable" == "" ] && \
  mongodb_last_stable=$last_mongodb_version

[ "rocksdb_last_stable" == "" ] && \
  rocksdb_last_stable=$last_rocksdb_version

mkdir -p versions

pushd versions || exit 666

echo "last_check=$(date '+%Y-%d-%m %H:%M')"> keyval.properties
echo "mongodb=${mongodb_last_stable}" >> keyval.properties
echo "rocksdb=${rocksdb_last_stable}" >> keyval.properties
popd