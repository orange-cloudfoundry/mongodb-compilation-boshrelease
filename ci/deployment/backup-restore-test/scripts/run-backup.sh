#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

cat ${ROOT_FOLDER}/deployment-specs/keyval.properties \
  | grep -v -E "^UPDATED|^UUID" \
  > ${ROOT_FOLDER}/deployment-specs/sourced.properties

source ${ROOT_FOLDER}/deployment-specs/sourced.properties


shield api --ca-cert "${SHIELD_CA}" ${SHIELD_CORE} shield-tests

export SHIELD_CORE=shield-tests

shield login

backup_ok=false

for ip in $(echo ${ips}|tr -s ',' ' ') 
do
	if ! ${backup_ok} ; then
		shield run-job "${ip}-backup-test" --yes
		[ $? -eq 0 ] && backup_ok=true 
	fi
done
