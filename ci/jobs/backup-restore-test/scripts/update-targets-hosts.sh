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
	
	target=$(buckler target ${SHIELD_TARGET}-${ip} --json | jq -r '.uuid') 
	
    buckler update-target ${target} -d mongo_host="rs0/${ips}" -d mongo_port="${MONGO_PORT}"

done
