#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-compilation-bosh-release-patched|| exit 666

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n deploy \
    ci/manifests/compilation.yml -v deployment=${DEPLOYMENT_NAME} -v release=${BOSH_RELEASE} \
    -v instance_group=${INSTANCE_GROUP} -v network=${NETWORK} -v director_uuid=${UUID} \
    -v version=$(grep "^mongodb" ${ROOT_FOLDER}/created/keyval.properties|cut -d"=" -f2)
popd

# copy uploaded to versions to be abble to reuse the upload config files task

mkdir -p deployed

pushd deployed || exit 666
echo "Compilation_date=$(date '+%Y-%d-%m %H:%M')"> keyval.properties
grep "^mongodb" ${ROOT_FOLDER}/created/keyval.properties >> keyval.properties
popd