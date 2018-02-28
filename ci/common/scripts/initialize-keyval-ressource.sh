#!/usr/bin/env sh 

set -ex

ROOT_FOLDER=${PWD}

mkdir -p ${ROOT_FOLDER}/output
cd ${ROOT_FOLDER}/output || exit 666
touch keyval.properties
