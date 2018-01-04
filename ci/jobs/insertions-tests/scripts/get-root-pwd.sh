#!/usr/bin/env sh 

set -ex

ROOT_FOLDER=${PWD}

set +x
credhub api ${IP}:${PORT} --skip-tls-validation
( echo ${USER} ; echo ${PASSWORD} ) \
    | credhub login
set -x

mkdir -p output
cd output || exit 666

credhub g -n /${BOSH_ALIAS}/mongodb-ci-rs/${VAR} -j |jq -r '.value' |sed -e "s/^/password=/">keyval.properties