#!/usr/bin/env sh 

# Remove every blobs that are not referenced in one of the blobs.yml files


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

mkdir -p ${ROOT_FOLDER}/clean-up

cd ${ROOT_FOLDER}/clean-up || exit 666

#retrieve all blobs.yml files
aws ${aws_opt} s3 cp --recursive s3://${BUCKET}/ci/ .

# retrieve the list of all uploaded blobs
aws ${aws_opt} s3 ls s3://${BUCKET} \
	| grep '[0-9a-z]*\-[0-9a-z]*\-[0-9a-z]*\-[0-9a-z]*\-[0-9a-z]*' \
	| awk '{print $4}' >> blobs.lst

cat blobs*.yml \
	| sed -e 's/^[[:space:]]*//g' \
	| grep "object_id:" \
	| awk '{print $2}' \
	| sort -u ) >> used_blobs.lst

# Proceed the purge
for i in $(cat blobs.lst)
do
	if [ $(grep $i used_blobs.lst|wc -l) -eq 0 ]
	then
		echo "Blob $i is not in use anywhere and will be remove"
		aws ${aws_opt} s3 rm s3://${BUCKET}/$i
	fi	
done

