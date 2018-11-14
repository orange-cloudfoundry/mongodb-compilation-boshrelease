#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

# removing deployment
bosh -e ${ALIAS} delete-deployment -n -d ${DEPLOYMENT_NAME}
