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

cd ci || exit 666
find . -type f -name '*.yml' -exec sh -c 'mv $1 $(echo $1|sed -e "s/\(^.*\)\.yml$/\1-ori.yml/")' {} {} \;
cd ${ROOT_FOLDER}

#upload all config yml files
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp --recursive ci s3://${BUCKET}/ci/

#renaming needed blobs (golang)
cat ${ROOT_FOLDER}/to_rename/blob_mv_list.lst | while read src dest
do
	aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 mv s3://${BUCKET}/${src} s3://${BUCKET}/${dest} 2>/dev/null
done