#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-compilation-bosh-release-patched|| exit 666

deployment_ops_files=""

if [ "${STEMCELL_TYPE}" == "centos" ]
then
    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-centos"
    BOSH_RELEASE="${BOSH_RELEASE}-centos"
    deployment_ops_files="${deployment_ops_files} \
                -o ${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/manifests/opsfiles/compilation-centos.yml"
else 
	STEMCELL_TYPE="ubuntu"
fi


# Updating final.yml with release name specified in settings
sed -i -e "s/^\(final_name:\).*/\1 ${BOSH_RELEASE}/" config/final.yml


deployment_var="  	-v deployment=${DEPLOYMENT_NAME} \
						-v release=${BOSH_RELEASE} \
    					-v instance_group=${INSTANCE_GROUP} \
    					-v network=${NETWORK} \
    					-v director_uuid=${UUID} \
    					-v version=$(grep '^mongodb' ${ROOT_FOLDER}/created/keyval.properties \
    					    								|cut -d'=' -f2)"


bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n deploy \
				${deployment_var} \
				ci/manifests/compilation.yml ${deployment_ops_files}
popd

# copy uploaded to versions to be abble to reuse the upload config files task

mkdir -p deployed

pushd deployed || exit 666
grep "^mongodb" ${ROOT_FOLDER}/created/keyval.properties >> keyval.properties
popd