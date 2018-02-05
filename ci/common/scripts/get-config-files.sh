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

mkdir -p ${ROOT_FOLDER}/mongodb-compilation-bosh-release-patched

cp -rp ${ROOT_FOLDER}/mongodb-compilation-bosh-release/. ${ROOT_FOLDER}/mongodb-compilation-bosh-release-patched

cd mongodb-compilation-bosh-release-patched || exit 666

#retrieve blob list
aws ${aws_opt} s3 \
	cp s3://${BUCKET}/ci/blobs-${MONGODB_VERSION}.yml config/blobs.yml 2>/dev/null \
	||echo "no archived blobs.yml, use release default one"

#retrieve final.yml
aws ${aws_opt} s3 \
	cp s3://${BUCKET}/ci/final-${MONGODB_VERSION}.yml config/final.yml 2>/dev/null \
	||echo "no archived final.yml, use release default one"

#retrieve private.yml
aws ${aws_opt} s3 \
	cp s3://${BUCKET}/ci/private-${MONGODB_VERSION}.yml config/private.yml 2>/dev/null \
	||echo "no archived private.yml, use release default one"

#get the list of availables blobs ids on blobsore
aws ${aws_opt} s3 ls s3://${BUCKET}/ 2>/dev/null > blobstore_ids.list