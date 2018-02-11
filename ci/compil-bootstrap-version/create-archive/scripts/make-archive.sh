#!/usr/bin/env bash

set -ex

ROOT_FOLDER=${PWD}

cp -rp mongodb-compilation-bosh-release-patched/. to-upload/

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml


if [ "${STEMCELL_TYPE}" == "centos" ]
then
    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-centos"
else
	STEMCELL_TYPE="ubuntu"
fi

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n run-errand make-tar --keep-alive

src_vm=$(bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} vms --column="instance"|tr -d [:space:])

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} scp \
${src_vm}:/var/vcap/store/make-tar/archive/mongodb-${STEMCELL_TYPE}-x86_64-*.tar.gz ${ROOT_FOLDER}/to-upload

pushd to-upload || exit 666

file=`ls mongodb-${STEMCELL_TYPE}-x86_64-*.tar.gz`

bosh -e ${ALIAS} add-blob $file mongodb/$file
bosh -e ${ALIAS} upload-blobs
# killing the vm
bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} vms \
	| grep "^${INSTANCE_GROUP}" \
	| awk '{print $5}' \
	| xargs -i -t bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n delete-vm {}

# needed to reuse upload-config-files
mkdir -p ${ROOT_FOLDER}/versions
cp -rp ${ROOT_FOLDER}/deployed/. ${ROOT_FOLDER}/versions
