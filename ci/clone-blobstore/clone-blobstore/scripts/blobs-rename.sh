#!/usr/bin/env sh 

set -ex

ROOT_FOLDER=${PWD}

mkdir -p ~/.aws

# create cert file needed for aws
cat > ~/.aws/credentials <<EOF 
[default]
aws_access_key_id=${ACCESS_KEY_ID}
aws_secret_access_key=${SECRET_ACCESS_KEY}
EOF

cd mongodb-bosh-release-patched || exit 666

# Renamming
cat  blob_mv_list.lst | while read src dst
do
	echo renamming ${src} to ${dst}
	aws --endpoint-url ${ENDPOINT_URL} \
	--no-verify-ssl s3 mv s3://${BUCKET}/${src} s3://${BUCKET}/${dst} \
	2>/dev/null 
done

# exporting config files ()

#retrieve final.yml
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp config/final.yml s3://${BUCKET}/ci/final.yml 2>/dev/null \

#retrieve private.yml
aws --endpoint-url ${ENDPOINT_URL} --no-verify-ssl s3 cp config/private.yml s3://${BUCKET}/ci/private.yml 2>/dev/null \
