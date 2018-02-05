#!/usr/bin/env bash 

set -ex

export ROOT_FOLDER=${PWD}

create_fake_files()
{
    # Creating fake files for already deployed releases

    if [ ! -d dev_releases/${RELEASE_NAME} ]
    then
        mkdir -p dev_releases/${RELEASE_NAME}
    fi

    for release in $(bosh -e ${ALIAS} releases | grep ${RELEASE_NAME} \
                    | sed -e 's/[^[:space:]]*[[:space:]]*\([^[:space:]]*\).*/\1/' | tr -d "*")
    do

        # get the hash of the release
        commit_hash=$(bosh -e ${ALIAS} releases --column="Version" --column="commit hash" \
                    | tr -d "*" | grep -w "^${release}" | tr -s "\t" " "|cut -d" " -f2 \
                    | tr -d [:space:] | tr -d "+")

        if [ ! -f dev_releases/${RELEASE_NAME}/index.yml ]
        then
            echo "builds:" > dev_releases/${RELEASE_NAME}/index.yml
        fi
        if [ ! -f dev_releases/${RELEASE_NAME}/${RELEASE_NAME}-${release}.yml ]
        then
            cat > dev_releases/${RELEASE_NAME}/${RELEASE_NAME}-${release}.yml <<EOF
name: ${DEPLOYMENT_NAME}
version: ${release}
commit_hash: ${commit_hash}
uncommitted_changes: false
EOF
            cat >> dev_releases/${RELEASE_NAME}/index.yml <<EOF
  $(cat /proc/sys/kernel/random/uuid):
    version: ${release}
EOF
        fi
    done    
}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

pushd mongodb-bosh-release-patched || exit 666

create_fake_files

# renaming final_name in final.yml

sed -i -e "s/\(^final_name: \).*$/\1 ${RELEASE_NAME}/" config/final.yml

# avoid checking jobs fingerprints
for i in $(find .final_builds -type d ! -path '*/packages' \
                           ! -path '*/packages/golang*' \
                           ! -path '.final_builds' \
                           -print )
do
        [ -d $i ] && rm -rf $i
done
deployment_var_init="   -v appli=${DEPLOYMENT_NAME} \
                        -v mongodb-release=${RELEASE_NAME} \
                        -v deployments-network=${DEPLOYMENT_NETWORK} \
                        -v shield-url=${SHIELD_URL} \
                        -v shield-token=${SHIELD_TOKEN} \
                        -v shield-tenant=${SHIELD_TENANT} \
                        -v shield-storage=${SHIELD_STORAGE} \
                        -v mongo-port=${MONGO_PORT} \
                        -v persistent-disk-type=${PERSISTENT_DISK_TYPE} \
                        -v vm-type=${VM_TYPE} \
                        -v root-username=${ROOT_USERNAME}"

deployment_ops_files_cmd=""

if [ "${STEMCELL}" != "" ]
then
    deployment_var_init="${deployment_var_init} \
                    -v stemcell=${STEMCELL}"
    deployment_ops_files_cmd="${deployment_ops_files_cmd} \
                    -o ${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/manifests/opsfiles/mongo-bootstrap-stemcell.yml"
fi

bosh -e ${ALIAS} cr --force

bosh -e ${ALIAS} ur 

bosh -e ${ALIAS} deploy -n -d mongodb-ci-rs \
        ${deployment_var_init} \
        ${ROOT_FOLDER}/mongodb-compilation-bosh-release/ci/manifests/manifest-rs-nossl.yml \
        ${deployment_ops_files_cmd}

popd

mkdir -p deployed

pushd deployed || exit 666
echo "Deployment_date=$(date '+%Y-%d-%m %H:%M')"> keyval.properties
popd