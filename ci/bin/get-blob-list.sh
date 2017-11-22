#!/usr/bin/env sh 

set -ex

ROOT_FOLDER=${PWD}

mkdir -p ~/.aws

# create cert file needed for aws
cat > ~/.aws/credentials <<EOF 
[default]
aws_access_key_id=$ACCESS_KEY_ID
aws_secret_access_key=$SECRET_ACCESS_KEY
EOF

mkdir -p ${ROOT_FOLDER}/mongodb-compilation-bosh-release-patched

rsync -ra ${ROOT_FOLDER}/mongodb-compilation-bosh-release/ ${ROOT_FOLDER}/mongodb-compilation-bosh-release-patched/

cd mongodb-compilation-bosh-release-patched || exit 666
#upload blob list
aws --endpoint-url $ENDPOINT_URL --no-verify-ssl s3 cp s3://$BUCKET/ci/blobs.yml config/blobs.yml