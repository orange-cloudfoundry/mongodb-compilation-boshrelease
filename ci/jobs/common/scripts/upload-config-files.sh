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

cd to-upload || exit 666
#upload blob list
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp config/blobs.yml s3://${BUCKET}/ci/blobs.yml 2>/dev/null
#upload final.yml
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp config/final.yml s3://${BUCKET}/ci/final.yml 2>/dev/null

mkdir -p ${ROOT_FOLDER}/uploaded
cd ${ROOT_FOLDER}/uploaded || exit 666
# create keyval file to indicate the end of sources upload job
echo "Upload_date=$(date '+%Y-%d-%m %H:%M')" > keyval.properties
# propagate mongodb version
grep "^mongodb" ${ROOT_FOLDER}/versions/keyval.properties >> keyval.properties