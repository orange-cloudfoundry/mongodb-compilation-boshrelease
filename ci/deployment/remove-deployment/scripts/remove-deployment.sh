#!/usr/bin/env bash 

set -ex

export ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

if [ "${STEMCELL_TYPE}" == "centos" ]
then
    # If we are on a centos deployment, deloyment name and release name will be suffixed
    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-centos"
    RELEASE_NAME="${RELEASE_NAME}-centos"
fi

bosh -e ${ALIAS} -n -d ${DEPLOYMENT_NAME} \
		delete-deployment

# remove release
bosh -e ${ALIAS} -n delete-release ${RELEASE_NAME}

# removing orphaned disks

for i in $(bosh -e ${ALIAS} -n disks --orphaned \
	| grep -w mongodb-ci-rs \
	| sed -e 's/\(^[^[:space:]]*\).*/\1/g')
do
	bosh -e ${ALIAS} -n -d ${DEPLOYMENT_NAME} delete-disk $i
done	

mkdir -p removed

pushd removed || exit 666
touch keyval.properties
popd