#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

source ${ROOT_FOLDER}/deployment-specs/keyval.properties 

CI_IP=`echo ${ips} \
	 | sed -e "s/,/:${PORT},/g" -e "s/$/:${PORT}/"`

mongo --host rs0/${CI_IP} -u ${USER} -p "${password}" --authenticationDatabase admin \
  --eval "db.testBackup.drop()"
