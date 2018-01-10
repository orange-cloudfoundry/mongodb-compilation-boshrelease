#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

source ${ROOT_FOLDER}/deployment-specs/keyval.properties

buckler api --ca-cert "${SHIELD_CA}" ${SHIELD_CORE} shield-tests

export SHIELD_CORE=shield-tests

buckler login


for ip in $(echo ${ips}|tr -s ',' ' ') # getting ips from deployment-specs
do
	# retrieving targets UUID
	target=$(buckler target ${SHIELD_TARGET}-${ip} --json | jq -r '.uuid') 

	# removing all jobs linked to target
	if [ "$target" != "" ]
	then
		for i in $(buckler jobs --target ${target} --json |jq -r '.[].uuid')
		do
			buckler delete-job $i --yes
		done

		# removing the target itself
		buckler delete-target ${target} --yes
	fi
done