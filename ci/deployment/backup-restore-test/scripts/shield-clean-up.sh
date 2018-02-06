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


for ip in $(echo ${ips}|tr -s ',' ' ') # getting ips from deployment-specs
do
	# retrieving targets UUID
	target=$(shield target ${SHIELD_TARGET}-${ip} --json | jq -r '.uuid') 

	# removing all jobs linked to target
	if [ "$target" != "" ]
	then
		for i in $(shield jobs --target ${target} --json |jq -r '.[].uuid')
		do
			shield delete-job $i --yes
		done

		# removing the target itself
		shield delete-target ${target} --yes
	fi
done