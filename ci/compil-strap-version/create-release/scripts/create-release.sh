#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-compilation-bosh-release-patched|| exit 666

# removing deployments which uses this release
bosh -e ${ALIAS} deployments | cat | grep ${BOSH_RELEASE}/${MONGODB_VERSION} | while read dep other
do
	bosh -e ${ALIAS} delete-deployment -n -d ${dep}
done

# removing already existing release if exists
bosh -e ${ALIAS} releases | cat | grep ${MONGODB_VERSION} | grep ${BOSH_RELEASE}|while read rel ver other
do
	bosh -e ${ALIAS} -n delete-release ${rel}/${ver}
done
 
bosh -e ${ALIAS} create-release --force --version ${MONGODB_VERSION}

bosh -e ${ALIAS} upload-release

popd

mkdir -p created

pushd created || exit 666
echo "Compilation_date=$(date '+%Y-%d-%m %H:%M')"> keyval.properties
grep "^mongodb" ${ROOT_FOLDER}/uploaded/keyval.properties >> keyval.properties
popd