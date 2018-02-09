#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-compilation-bosh-release-patched|| exit 666


deployment_var_init="  	-v deployment=${DEPLOYMENT_NAME} \
						-v release=${BOSH_RELEASE} \
    					-v instance_group=${INSTANCE_GROUP} \
    					-v network=${NETWORK} \
    					-v director_uuid=${UUID} \
    					-v version=$(grep '^mongodb' ${ROOT_FOLDER}/created/keyval.properties \
    					    								|cut -d'=' -f2)"

deployment_ops_files_cmd=""

if [ "${STEMCELL_TYPE}" == "centos" ]
then
    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-centos"
    RELEASE_NAME="${RELEASE_NAME}-centos"
    deployment_ops_files_cmd="${deployment_ops_files_cmd} \
                -o ${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/manifests/opsfiles/compilation-centos.yml"
fi

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n deploy \
				${deployment_var_init} \
				ci/manifests/compilation.yml ${deployment_ops_files_cmd}
popd

# copy uploaded to versions to be abble to reuse the upload config files task

mkdir -p deployed

pushd deployed || exit 666
echo "Compilation_date=$(date '+%Y-%d-%m %H:%M')"> keyval.properties
grep "^mongodb" ${ROOT_FOLDER}/created/keyval.properties >> keyval.properties
popd