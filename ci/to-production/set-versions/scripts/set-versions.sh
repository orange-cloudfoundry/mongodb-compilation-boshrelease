#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

if [ "${MONGO_VERSION}" != "" ]
then
	mongodb_version=${MONGO_VERSION}
elif [ -s ${ROOT_FOLDER}/mongodb-version/version ] 
then
    mongodb_version=$(cat ${ROOT_FOLDER}/mongodb-version/version)	
else
	echo "Cannot find a valid Mongodb version to deploy" && exit 666
fi

# for testing purpose
mongodb_version=3.4.7

mkdir -p versions

pushd versions || exit 666

echo "mongodb=${mongodb_version}" >> keyval.properties
popd