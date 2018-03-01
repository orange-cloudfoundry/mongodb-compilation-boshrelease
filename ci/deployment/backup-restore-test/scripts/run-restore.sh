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

shield api --ca-cert "${SHIELD_CA}" ${SHIELD_CORE} shield-tests

export SHIELD_CORE=shield-tests

ips=`eval echo \\$${STEMCELL_TYPE} \
   | jq -r '.ips'`

shield login

restore_ok=false

for ip in $(echo ${ips}|tr -s ',' ' ') # getting ips from deployment-specs
do
	target=$(shield target ${SHIELD_TARGET}-${ip} --json | jq -r '.uuid')

	archive=$(shield archives --target ${target} --json \
		| jq -r '.[] | select(.status |contains("valid"))|.uuid')

	if ! ${restore_ok}; then
		if [ "${archive}" != "" ] ; then
			shield restore-archive "${archive}"
			[ $? -eq 0 ] && restore_ok=true 
		fi
	fi

done