#!/usr/bin/env bash

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

bosh -e ${ALIAS} -d mongodb-ci-rs run-errand acceptance-tests
