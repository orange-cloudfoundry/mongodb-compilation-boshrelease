#!/usr/bin/env bash

set -ex

ROOT_FOLDER=${PWD}

cp -rp mongodb-compilation-bosh-release-patched/. to-upload/

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n run-errand make-tar --keep-alive

src_vm=$(bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} vms --column="instance"|tr -d [:space:])

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} scp \
${src_vm}:/var/vcap/store/make-tar/archive/mongodb-linux-x86_64-*.tar.gz ${ROOT_FOLDER}/to-upload

pushd to-upload || exit 666

file=`ls mongodb-linux-x86_64-*.tar.gz`

bosh -e ${ALIAS} add-blob $file mongodb/$file
bosh -e ${ALIAS} upload-blobs
bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n delete-vm $(bosh -e ${ALIAS} -d \
  ${DEPLOYMENT_NAME} vms --column="vm cid")
