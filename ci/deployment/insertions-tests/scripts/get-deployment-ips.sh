#!/usr/bin/env bash 

set -ex

export ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

if [ "${STEMCELL_TYPE}" == "centos" ]
then
    # If we are on a centos deployment, deloyment name will be suffixed
    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-centos"
else
    STEMCELL_TYPE="ubuntu"    
fi

pushd output || exit 666

[ -d ${ROOT_FOLDER}/deployment-specs ] && cp -rp ${ROOT_FOLDER}/deployment-specs/* .

[ ! -f keyval.properties ] && exit 666

val=$(bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} vms --column Ips | sed -e 's/[[:space:]]*$/,/g' \
			|tr -d "\n" \
			|sed -e 's/,$//' -e 's/^/"ips":\"/' -e 's/$/\"/')
sed -i -e "s/\(^${STEMCELL_TYPE}.*\)}$/\1,${val}}/" keyval.properties
			
popd