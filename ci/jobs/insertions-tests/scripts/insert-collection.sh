#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

source ${ROOT_FOLDER}/deployment-specs/keyval.properties 

CI_IP=`echo ${ips} \
	 | sed -e "s/,/:${PORT},/g" -e "s/$/:${PORT}/"`

# remove collection before insertion

mongo --host rs0/${CI_IP} -u ${USER} -p "${password}" --authenticationDatabase admin \
  --eval "db.testBackup.drop()"

mongo --host rs0/${CI_IP} -u ${USER} -p "${password}" --authenticationDatabase admin <<-EOF
	for (var i = 1; i <= 5; i++) {
	db.testBackup.insert( { x : i, y : Math.floor(Math.random() * ((1000000 + 1) - 1)) + 1 } )
	}
	EOF

cd ${ROOT_FOLDER}/filled || exit 666

mongo --host rs0/${CI_IP} -u ${USER} -p "${password}" --authenticationDatabase admin \
  --eval  "db.testBackup.find({},{_id:0})" \
  | grep "^{" | tr -d ' ' \
  | sed -e 's/.[^:]*:\([0-9]*\).[^:]*:\([0-9]*\).*/\1=\2/' \
  > keyval.properties