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

aws configure set default.s3.signature_version s3v${SIGNATURE_VERSION}

# removing all files 
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 rm --recursive s3://${BUCKET} 2>/dev/null

mkdir -p ${ROOT_FOLDER}/cleaned

touch ${ROOT_FOLDER}/cleaned/keyval.properties || exit 666