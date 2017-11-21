#!/usr/bin/env bash 

set -ex

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-compilation-bosh-release|| exit 666

# Creating fake files for already deployed releases
if [ ! -d dev_releases/${BOSH_RELEASE} ]
then
    mkdir -p dev_releases/${BOSH_RELEASE}
fi

for release in $(bosh -e ${ALIAS} releases -d ${DEPLOYMENT_NAME} --column="Version")
do
    release=$(echo $release|sed -e "s/\*$//")
    commit_hash=$(bosh -e ${ALIAS} releases -d ${DEPLOYMENT_NAME} --column="commit hash")
    if [ ! -f dev_releases/${BOSH_RELEASE}/index.yml ]
    then
        echo "builds:" > dev_releases/${BOSH_RELEASE}/index.yml
    fi
    if [ ! -f dev_releases/${BOSH_RELEASE}/${BOSH_RELEASE}-${release}.yml ]
    then
        cat > dev_releases/${BOSH_RELEASE}/${BOSH_RELEASE}-${release}.yml <<EOF
        name: ${DEPLOYMENT_NAME}
        version: ${release}
        commit_hash: ${commit_hash}
        uncommitted_changes: false
EOF
        cat >> dev_releases/((bosh-deployment.release))/index.yml <<EOF
        $(cat /proc/sys/kernel/random/uuid):
        version: ${release}
EOF
    fi
done

bosh -e ${ALIAS} create-release --force

bosh -e ${ALIAS} upload-release

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n deploy \
manifest.yml -o ci/concourse-network.yml

popd