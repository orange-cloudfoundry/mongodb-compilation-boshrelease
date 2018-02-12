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

if [ "${MONGODB_VERSION}" == "" ]
then
  MONGODB_VERSION=`grep "^mongodb" ${ROOT_FOLDER}/versions/keyval.properties|cut -d"=" -f2`
fi

aws_opt="--endpoint-url ${ENDPOINT_URL}"

if ${SKIP_SSL}
then
  aws_opt="${aws_opt} --no-verify-ssl"
else 
  if [ "${SSL_CERT}" == "" ]
  then
    echo "You Have to provide an ssl certificate"
    exit 666
  else 
    cat > /tmp/ca-bundle.crt <<-EOF
	${SSL_CERT}
	EOF
	aws_opt="${aws_opt} --ca-bundle /tmp/ca-bundle.crt"   
  fi
fi

cd to-upload || exit 666
#upload blob list
aws ${aws_opt} s3 cp config/blobs.yml s3://${BUCKET}/ci/blobs-${MONGODB_VERSION}.yml
#upload final.yml
aws ${aws_opt} s3 cp config/final.yml s3://${BUCKET}/ci/final-${MONGODB_VERSION}.yml
#upload private.yml
aws ${aws_opt} s3 cp config/private.yml s3://${BUCKET}/ci/private-${MONGODB_VERSION}.yml


mkdir -p ${ROOT_FOLDER}/uploaded
cd ${ROOT_FOLDER}/uploaded || exit 666
touch keyval.properties