#!/usr/bin/env bash 

set -ex

create_fake_files()
{
    # Creating fake files for already deployed releases

    if [ ! -d dev_releases/${BOSH_RELEASE} ]
    then
        mkdir -p dev_releases/${BOSH_RELEASE}
    fi

    for release in $(bosh -e ${ALIAS} releases -d ${DEPLOYMENT_NAME} --column="Version"|tr -d"*")
    do

        # get the hash of the release
        commit_hash=$(bosh -e ${ALIAS} releases -d ${DEPLOYMENT_NAME} --column="Version" --column="commit hash" \
                    |tr -d "*" |grep -w "^${release}"|tr -s [:space:]|cut -d" " -f2|tr -d [:space:])

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
            cat >> dev_releases/${BOSH_RELEASE}/index.yml <<EOF
            $(cat /proc/sys/kernel/random/uuid):
            version: ${release}
EOF
        fi
    done    
}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-compilation-bosh-release|| exit 666

create_fake_files

bosh -e ${ALIAS} create-release --force

bosh -e ${ALIAS} upload-release

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n deploy \
manifest.yml -o ci/concourse-network.yml

popd