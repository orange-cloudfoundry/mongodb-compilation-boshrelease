#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

source ${ROOT_FOLDER}/deployment-specs/keyval.properties

buckler api --ca-cert "${SHIELD_CA}" ${SHIELD_CORE} shield-tests

export SHIELD_CORE=shield-tests

buckler login

backup_ok=false

for ip in $(echo ${ips}|tr -s ',' ' ') # getting ips from deployment-specs
do
	if ! ${backup_ok} ; then
		buckler run-job "${ip}-backup-test" --yes
		[ $? -eq 0 ] && backup_ok=true 
	fi
done