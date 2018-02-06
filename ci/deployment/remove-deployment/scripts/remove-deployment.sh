#!/usr/bin/env bash 

set -ex

export ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

bosh -e ${ALIAS} -n -d ${DEPLOYMENT_NAME} \
		delete-deployment

# remove release
bosh -e ${ALIAS} -n delete-release ${RELEASE_NAME}

# removing orphaned disks

for i in $(bosh -e ${ALIAS} -n disks --orphaned \
	| grep -w mongodb-ci-rs \
	| sed -e 's/\(^[^[:space:]]*\).*/\1/g')
do
	bosh -e ${ALIAS} -n -d mongodb-ci-rs delete-disk $i
done	

mkdir -p removed

pushd removed || exit 666
touch keyval.properties
popd