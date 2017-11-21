#!/usr/bin/env bash -exc

ROOT_FOLDER=${PWD}

pushd mongodb-compilation-bosh-release

for i in $(find ${ROOT_FOLDER}/downloaded-src -type f -name '*.tar.gz' -print)
do
  product=$(basename $(dirname $i))
  archive=$(basename $i)
  bosh add-blob $i $product/$archive
  bosh -e $ALIAS upload-blobs
done

popd

rsync -ra mongodb-compilation-bosh-release/ to-upload/