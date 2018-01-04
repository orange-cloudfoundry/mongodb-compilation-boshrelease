#!/usr/bin/env sh

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

mongo --host rs0/${CI_IP}

# needed to reuse upload-config-files
mkdir -p ${ROOT_FOLDER}/versions
cp -rp ${ROOT_FOLDER}/compiled/. ${ROOT_FOLDER}/versions
