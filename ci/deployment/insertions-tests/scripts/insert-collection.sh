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
  --eval "if (db.${COLLECTION}.exists()){db.${COLLECTION}.drop()}"

mongo "mongodb://${CI_IP}/${DB}?replicaSet=rs0" -u ${USER} -p "${password}" --authenticationDatabase admin \
  --eval "for (var i = 1; i <= 5; i++) {
						db.${COLLECTION}.insert( { x : i, y : Math.floor(Math.random() * ((1000000 + 1) - 1)) + 1 } )
					}"

cd ${ROOT_FOLDER}/datas || exit 666

mongo "mongodb://${CI_IP}/${DB}?replicaSet=rs0" -u ${USER} -p "${password}" --authenticationDatabase admin \
  --eval "db.${COLLECTION}.find({},{_id:0})" \
						| grep "^{" | tr -d ' ' \
						| sed -e 's/.[^:]*:\([0-9]*\).[^:]*:\([0-9]*\).*/\1=\2/' \
						> keyval.properties