#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

pushd to-upload-pre

for i in $(find ${ROOT_FOLDER}/downloaded-src -type f -name '*.tar.gz' -print)
do
  product=$(basename $(dirname $i))
  archive=$(basename $i)
  version=$(${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/bin/get-archive-version.pl ${archive})
  prefix=$(echo ${archive}|sed -e "s/\(.*\)${version}.*/\1/")
  bosh -e $ALIAS blobs| grep "^${product}/${prefix}" | grep -v $version | cut -d" " -f1
done

popd

rsync -ra to-upload-pre/ to-upload/