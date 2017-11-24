#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

cp -rp to-upload-pre/. to-upload

pushd to-upload

# Updating final.yml with release name specified in settings
sed -i -e "s/^\(final_name:\).*/\1 ${BOSH_RELEASE}/" config/final.yml

# Remove previous blobs to keep only the last versions ones
for i in $(find ${ROOT_FOLDER}/downloaded-src -type f -name '*.tar.gz' -print)
do
    product="$(basename $(dirname $i))"
    archive="$(basename $i)"
    version=$(${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/bin/get-archive-version.pl -v ${archive})
    prefix=$(${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/bin/get-archive-version.pl -p ${archive})

    # removing old blobs
    for j in $(bosh -e $ALIAS blobs|sed -e $"s/\t/ /g" | cut -d" " -f1 | grep "^${product}/${prefix}" \
                                    | grep -v "$version" | tr -s [:space:] )
    do
        bosh -e $ALIAS -n remove-blob $j
    done
done

popd
