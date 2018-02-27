#!/usr/bin/env sh 

set -ex

ROOT_FOLDER=${PWD}

set +x
credhub api ${IP}:${PORT} --skip-tls-validation
( echo ${USER} ; echo ${PASSWORD} ) \
    | credhub login
set -x

if [ "${STEMCELL_TYPE}" == "centos" ]
then
    # If we are on a centos deployment, deloyment name will be suffixed
    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-centos"
else
	STEMCELL_TYPE="ubuntu"   
fi

mkdir -p output
cd output || exit 666

# retrieving existing specs datas
[ -d ${ROOT_FOLDER}/deployment-specs ] && cp -rp ${ROOT_FOLDER}/deployment-specs/* .

# removing existing values from properties

sed -i -e '/^${STEMCELL_TYPE}/d' keyval.properties
password=$(credhub g -n /${BOSH_ALIAS}/${DEPLOYMENT_NAME}/${VAR} -j |jq -r '.value')
content=$(echo "{}"|jq -c '. |= . + {"password":"'${password}'"}')

echo "${STEMCELL_TYPE}=$content" >> keyval.properties