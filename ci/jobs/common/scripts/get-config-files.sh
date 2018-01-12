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

cp -rp ${ROOT_FOLDER}/mongodb-compilation-bosh-release/. ${ROOT_FOLDER}/mongodb-compilation-bosh-release-patched

cd mongodb-compilation-bosh-release-patched || exit 666

#retrieve blob list
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp s3://${BUCKET}/ci/blobs.yml config/blobs.yml 2>/dev/null \
||echo "no archived blobs.yml, use release default one"

#retrieve final.yml
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp s3://${BUCKET}/ci/final.yml config/final.yml 2>/dev/null \
||echo "no archived final.yml, use release default one"

#get the list of availables blobs ids on blobsore
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 ls s3://${BUCKET}/ 2>/dev/null > blobstore_ids.list