#!/usr/bin/env bash 

set -ex

ROOT_FOLDER=${PWD}

create_fake_files()
{
    # Creating fake files for already deployed releases

    if [ ! -d dev_releases/${BOSH_RELEASE} ]
    then
        mkdir -p dev_releases/${BOSH_RELEASE}
    fi

    for release in $(bosh -e ${ALIAS} releases | grep ${BOSH_RELEASE} \
                    | sed -e 's/[^[:space:]]*[[:space:]]*\([^[:space:]]*\).*/\1/' | tr -d "*")
    do

        # get the hash of the release
        commit_hash=$(bosh -e ${ALIAS} releases --column="Version" --column="commit hash" \
                    | tr -d "*" | grep -w "^${release}" | tr -s "\t" " "|cut -d" " -f2 \
                    | tr -d [:space:] | tr -d "+")

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

pushd mongodb-compilation-bosh-release-patched|| exit 666

create_fake_files

bosh -e ${ALIAS} create-release --force

bosh -e ${ALIAS} upload-release

bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} -n deploy \
    ci/manifests/compilation.yml -v deployment=${DEPLOYMENT_NAME} -v release=${BOSH_RELEASE} \
    -v instance_group=${INSTANCE_GROUP} -v network=${NETWORK} -v director_uuid=${UUID} \
    -v version=$(grep "^mongodb" ${ROOT_FOLDER}/uploaded/keyval.properties|cut -d"=" -f2)
popd

# copy uploaded to versions to be abble to reuse the upload config files task

mkdir -p compiled

pushd compiled || exit 666
echo "Compilation_date=$(date '+%Y-%d-%m %H:%M')"> keyval.properties
grep "^mongodb" ${ROOT_FOLDER}/uploaded/keyval.properties >> keyval.properties
popd