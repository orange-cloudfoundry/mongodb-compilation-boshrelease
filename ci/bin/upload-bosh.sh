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
  # do not upload again already available blob - prevent blobstore to have the same blob twice
  available=$(grep $(bosh blobs --column="path" --column="blobstore id" \
                |grep "^${product}/${archive}" |tr -s "\t" " "|tr -s [:space:]|cut -d" " -f2) blobstore_ids.list|wc -l)
  if [ $available -eq 0 ]
  then
    bosh add-blob $i ${product}/${archive}
  else
    echo "blob ^${product}/${archive} is already present in blobstore"   
  fi
done
bosh -e ${ALIAS} upload-blobs

popd

