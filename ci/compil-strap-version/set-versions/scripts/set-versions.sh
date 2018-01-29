#!/usr/bin/env bash 

set -ex

mongodb_strap=${MONGO_VERSION}
rocksdb_strap=${ROCKS_VERSION}

mkdir -p versions

pushd versions || exit 666

echo "last_check=$(date '+%Y-%d-%m %H:%M')"> keyval.properties
echo "mongodb=${mongodb_strap}" >> keyval.properties
echo "rocksdb=${rocksdb_strap}" >> keyval.properties
popd