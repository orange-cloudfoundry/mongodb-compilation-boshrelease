#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

cat ${ROOT_FOLDER}/deployment-specs/keyval.properties \
  | grep -v -E "^UPDATED|^UUID" \
  | sed -e 's/"/\\"/g' \
  > ${ROOT_FOLDER}/deployment-specs/sourced.properties

source ${ROOT_FOLDER}/deployment-specs/sourced.properties 

if [ "${STEMCELL_TYPE}" != "centos" ]
then
  STEMCELL_TYPE="ubuntu"   
fi

CI_IP=`eval echo \\$${STEMCELL_TYPE} \
	| jq -r '.ips' \
	| sed -e "s/,/:${PORT},/g" -e "s/$/:${PORT}/"`

password=`eval echo \\$${STEMCELL_TYPE} \
   | jq -r '.password'`	

# get mongodb server version

installed_version=$(mongo --host rs0/${CI_IP} -u ${USER} -p "${password}" --authenticationDatabase admin \
  --eval "db.version()"|tail -1)

needed_version=$(grep "^mongodb" ${ROOT_FOLDER}/versions/keyval.properties|cut -d"=" -f2)

if [ "${installed_version}" != "${needed_version}" ] 
then
	echo "Mongodb server version is ${installed_version} and don\'t match expected one (${needed_version})" \
  exit 666
fi

# checking values in db

cat ${ROOT_FOLDER}/filled/keyval.properties| grep -v -E "^UPDATED|^UUID" |tr -s '=' ' '|while read x y
do
	mongo --host rs0/${CI_IP} -u ${USER} -p "${password}" --authenticationDatabase admin \
 		--eval "if (db.testBackup.find({x:$x,y:$y}).count() == 0)
 				{
 					throw new Error('values (x:$x,y:$y) not found in collection');
 				}" --quiet
done