#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

if [ "${STEMCELL_TYPE}" == "centos" ]
then
    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-centos"
else 
	STEMCELL_TYPE="ubuntu"
fi


# removing deployment
bosh -e ${ALIAS} delete-deployment -n -d ${DEPLOYMENT_NAME}
