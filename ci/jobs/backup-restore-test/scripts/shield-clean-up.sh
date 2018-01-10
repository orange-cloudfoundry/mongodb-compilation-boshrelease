#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

buckler api --ca-cert "${SHIELD_CA}" ${SHIELD_CORE} shield-tests

export SHIELD_CORE=shield-tests

buckler login

# retrieving target UUID

target=$(buckler target ${SHIELD_TARGET} --json | jq -r '.uuid')

# removing all jobs linked to target

for i in $(buckler jobs --target ${target} --json |jq -r '.[].uuid')
do
	buckler delete-job $i --yes
done

# removing the target itself
buckler delete-target ${target} --yes