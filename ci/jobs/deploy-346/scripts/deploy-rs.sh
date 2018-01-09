#!/usr/bin/env bash 

set -ex

export ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-bosh-release-patched || exit 666

# renaming final_name in final.yml

sed -i -e "s/\(^final_name: \).*$/\1 ${RELEASE_NAME}/" config/final.yml

# avoid checking jobs fingerprints
rm -rf .final_*

bosh -e ${ALIAS} cr --force

bosh -e ${ALIAS} ur 

bosh -e ${ALIAS} deploy -n -d mongodb-ci-rs \
        -v appli=${DEPLOYMENT_NAME} \
        -v mongodb-release=${RELEASE_NAME} \
        -v deployments-network=${DEPLOYMENT_NETWORK} \
        -v shield-url=${SHIELD_URL} \
        -v shield-token=${SHIELD_TOKEN} \
        -v shield-tenant=${SHIELD_TENANT} \
        -v mongo-port=${MONGO_PORT} \
        -v persistent-disk-type=${PERSISTENT_DISK_TYPE} \
        -v vm-type=${VM_TYPE} \
        -v root-username=${ROOT_USERNAME} \
        ${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/manifests/manifest-rs-nossl.yml

popd

mkdir -p deployed

pushd deployed || exit 666
echo "Deployment_date=$(date '+%Y-%d-%m %H:%M')"> keyval.properties
popd