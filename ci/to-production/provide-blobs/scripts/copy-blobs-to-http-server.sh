#!/usr/bin/env sh 


# To do this works http server have to run on the same server than s3 one 
# and http server root directory have to be a bucket of minio

set -ex

ROOT_FOLDER=${PWD}

mkdir -p ~/.aws

# create cert file needed for aws
cat > ~/.aws/credentials <<EOF 
[default]
aws_access_key_id=$ACCESS_KEY_ID
aws_secret_access_key=$SECRET_ACCESS_KEY
EOF

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

mkdir -p ${ROOT_FOLDER}/output

echo "Hi All,

A new version of mongodb has been compiled and has passed all submitted tests.
Please upload the following blobs to the production s3 server:
" > ${ROOT_FOLDER}/output/mail.body

cat ${ROOT_FOLDER}/blobs-list/blobs.lst| tr -s ':' ' ' |while read src dst sha
do
	aws ${aws_opt} s3 \
		cp s3://${BUCKET}/${src} s3://${HTTP_BUCKET}/${dst} \
		||echo "archive not found"
	echo ${sha} > $dst.sha1
	aws ${aws_opt} s3 \
		cp $dst.sha1 s3://${HTTP_BUCKET}

	echo "	http://${HTTP_IP}:${HTTP_PORT}/${dst}" >> ${ROOT_FOLDER}/output/mail.body
done

echo "

A new final release should be created using theses blobs

Thanks in advance" >> ${ROOT_FOLDER}/output/mail.body
