#!/usr/bin/env sh -exc

mkdir -p ~/.aws

# create cert file needed for aws
cat > ~/.aws/credentials <<EOF 
[default]
aws_access_key_id=$ACCESS_KEY_ID
aws_secret_access_key=$SECRET_ACCESS_KEY
EOF

cd to-upload || exit 666
#upload blob list
aws --endpoint-url $ENDPOINT_URL --no-verify-ssl s3 cp config/blobs.yml s3://$BUCKET/ci/blobs.yml