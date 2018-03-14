#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

cat ${ROOT_FOLDER}/deployment-specs/keyval.properties \
  | grep -v -E "^UPDATED|^UUID" \
  > ${ROOT_FOLDER}/deployment-specs/sourced.properties

source ${ROOT_FOLDER}/deployment-specs/sourced.properties 

if [ "${STEMCELL_TYPE}" != "centos" ]
then
  STEMCELL_TYPE="ubuntu"   
fi

CI_IP=`echo ${ips} \
	 | sed -e "s/,/:${PORT},/g" -e "s/$/:${PORT}/"`

# remove collection before insertion

mongo "mongodb://${CI_IP}/${DB}?replicaSet=rs0" -u ${USER} -p "${password}" --authenticationDatabase admin \
  --eval "db.${COLLECTION}.drop()"

cat ${ROOT_FOLDER}/datas/keyval.properties| grep -v -E "^UPDATED|^UUID" |tr -s '=' ' '|while read x y
do
  mongo "mongodb://${CI_IP}/${DB}?replicaSet=rs0" -u ${USER} -p "${password}" --authenticationDatabase admin \
    --eval "db.${COLLECTION}.insert( { x : ${x}, y : ${y} })" --quiet
done