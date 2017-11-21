#!/busr/bin/env bash

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml
pushd mongodb-compilation-bosh-release || exit 666

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n run-errand make-tar --keep-alive

src_vm=$(bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} vms --column="instance"|tr -d [:space:])

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} scp \
${src_vm}:/var/vcap/store/make-tar/archive/mongodb-linux-x86_64-*.tar.gz .

file=`ls mongodb-linux-x86_64-*.tar.gz`
echo file: $file
bosh -e ${ALIAS} add-blob $file mongodb/$file
bosh -e ${ALIAS} upload-blobs
bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n delete-vm $(bosh -e ${ALIAS} -d \
  ${DEPLOYMENT_NAME} vms --column="vm cid")

popd

rsync -ra mongodb-compilation-bosh-release/ to-upload/