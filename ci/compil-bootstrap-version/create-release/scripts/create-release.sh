#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-compilation-bosh-release-patched|| exit 666

if [ "${STEMCELL_TYPE}" == "centos" ]
then
    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-centos"
    BOSH_RELEASE="${BOSH_RELEASE}-centos"
else 
	STEMCELL_TYPE="ubuntu"
fi

# Updating final.yml with release name specified in settings
sed -i -e "s/^\(final_name:\).*/\1 ${BOSH_RELEASE}/" config/final.yml


# removing deployments which uses this release
bosh -e ${ALIAS} deployments | cat | grep ${BOSH_RELEASE}/${MONGODB_VERSION} | while read dep other
do
	bosh -e ${ALIAS} delete-deployment -n -d ${dep}
done

# removing already existing release if exists
bosh -e ${ALIAS} releases | cat | grep ${MONGODB_VERSION} |while read rel ver other
do
	if [ "${rel}" == "${BOSH_RELEASE}" ]
	then	
		bosh -e ${ALIAS} -n delete-release ${rel}/${ver}
	fi
done
 
bosh -e ${ALIAS} create-release --force --version ${MONGODB_VERSION}

bosh -e ${ALIAS} upload-release

popd

mkdir -p created

pushd created || exit 666
grep "^mongodb" ${ROOT_FOLDER}/uploaded/keyval.properties >> keyval.properties
popd