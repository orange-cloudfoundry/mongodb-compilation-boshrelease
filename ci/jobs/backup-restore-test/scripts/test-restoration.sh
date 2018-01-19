#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

cat ${ROOT_FOLDER}/deployment-specs/keyval.properties \
  | grep -v -E "^UPDATED|^UUID" \
  > ${ROOT_FOLDER}/deployment-specs/sourced.properties

source ${ROOT_FOLDER}/deployment-specs/sourced.properties 

CI_IP=`echo ${ips} \
	 | sed -e "s/,/:${PORT},/g" -e "s/$/:${PORT}/"`


cat ${ROOT_FOLDER}/filled/keyval.properties|tr -s '=' ' '|while read x y
do
	mongo --host rs0/${CI_IP} -u ${USER} -p "${password}" --authenticationDatabase admin \
 		--eval "if (db.testBackup.find({x:$x,y:$y}).count() == 0)
 				{
 					throw new Error('values (x:$x,y:$y) not found in collection');
 				}" --quiet
done