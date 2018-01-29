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

if [ "${MONGODB_VERSION}" == ""]
then
  MONGODB_VERSION=`grep "^mongodb" ${ROOT_FOLDER}/versions/keyval.properties|cut -d"=" -f2`
fi

cd to-upload || exit 666
#upload blob list
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp config/blobs.yml s3://${BUCKET}/ci/blobs-${MONGODB_VERSION}.yml 2>/dev/null
#upload final.yml
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp config/final.yml s3://${BUCKET}/ci/final-${MONGODB_VERSION}.yml 2>/dev/null
#upload private.yml
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp config/private.yml s3://${BUCKET}/ci/private-${MONGODB_VERSION}.yml 2>/dev/null


mkdir -p ${ROOT_FOLDER}/uploaded
cd ${ROOT_FOLDER}/uploaded || exit 666
# create keyval file to indicate the end of sources upload job
echo "Upload_date=$(date '+%Y-%d-%m %H:%M')" > keyval.properties
# propagate mongodb version
grep "^mongodb" ${ROOT_FOLDER}/versions/keyval.properties >> keyval.properties