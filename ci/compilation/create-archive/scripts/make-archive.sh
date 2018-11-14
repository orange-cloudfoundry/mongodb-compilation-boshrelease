#!/usr/bin/env bash

set -ex

ROOT_FOLDER=${PWD}

cp -rp mongodb-compilation-bosh-release-patched/. mongodb-compilation-bosh-release-archive/

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n run-errand create-mongodb-archive --keep-alive

src_vm=$(bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} vms --column="instance"|tr -d [:space:])

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} scp \
${src_vm}:/var/vcap/store/create-mongodb-archive/archive/mongodb-ubuntu-x86_64-*.tar.gz ${ROOT_FOLDER}/mongodb-compilation-bosh-release-archive

# killing the vm
bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} vms \
	| grep "^${INSTANCE_GROUP}" \
	| awk '{print $5}' \
	| xargs -i -t bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n delete-vm {}

pushd mongodb-compilation-bosh-release-archive || exit 666

file=`ls mongodb-*-x86_64-*.tar.gz`

bosh -e ${ALIAS} add-blob $file mongodb/$file
bosh -e ${ALIAS} upload-blobs
