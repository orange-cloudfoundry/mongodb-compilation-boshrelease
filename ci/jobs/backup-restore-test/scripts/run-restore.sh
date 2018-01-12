#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

source ${ROOT_FOLDER}/deployment-specs/keyval.properties

buckler api --ca-cert "${SHIELD_CA}" ${SHIELD_CORE} shield-tests

export SHIELD_CORE=shield-tests

buckler login

restore_ok=false

for ip in $(echo ${ips}|tr -s ',' ' ') # getting ips from deployment-specs
do
	target=$(buckler target ${SHIELD_TARGET}-${ip} --json | jq -r '.uuid')

	archive=$(buckler archives --target ${target} --json \
		| jq -r '.[] | select(.status |contains("valid"))|.uuid')

	if ! ${restore_ok}; then
		if [ "${archive}" != "" ] ; then
			buckler restore-archive "${archive}"
			[ $? -eq 0 ] && restore_ok=true 
		fi
	fi

done