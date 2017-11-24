#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}
export BOSH_CONFIG=${ROOT_FOLDER}/bosh-director-config/bosh_config.yml

rsync -ra mongodb-compilation-bosh-release-patched/ to-upload-pre/

pushd to-upload-pre || exit 666

for i in $(find ${ROOT_FOLDER}/downloaded-src -type f -name '*.tar.gz' -print)
do
  product=$(basename $(dirname $i))
  archive=$(basename $i)
  bosh add-blob $i $product/$archive
  bosh -e $ALIAS upload-blobs
done

popd

