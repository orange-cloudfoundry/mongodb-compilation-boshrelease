#!/usr/bin/env bash 

set -ex

export ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-bosh-release-patched || exit 666

# renaming final_name in final.yml

sed -i -e "s/\(^final_name: \).*$/\1 mongodb-ci-rs/" config/final.yml

# avoid checking jobs fingerprints
rm -rf .final_*

bosh -e ${ALIAS} cr --force

bosh -e ${ALIAS} ur 

bosh -e ${ALIAS} -d mongodb-ci-rs -v appli=mongodb-ci-rs ${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/manifests/manifest-rs-nossl.yml

popd