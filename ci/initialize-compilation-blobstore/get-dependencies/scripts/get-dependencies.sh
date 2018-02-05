#!/usr/bin/env bash

set -ex

export ROOT_FOLDER=${PWD}

export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

# installing needed packages
apt update
apt install -y curl jq python python-yaml

mkdir -p ci to_rename

cd mongodb-compilation-bosh-release || exit 666

# removing old files
rm -f config/*.yml

# generating new final.yml
cat > config/final.yml <<-EOF
	---
	final_name: bidon
	blobstore:
	  provider: s3
	  options:
	    bucket_name: ${BUCKET}
	    host: ${ENDPOINT_URL}
	EOF

# feeding private.yml
cat > config/private.yml <<-EOF
	---
	blobstore:
	  options:
	    access_key_id: '${ACCESS_KEY_ID}'
	    secret_access_key: '${SECRET_ACCESS_KEY}'
	    ssl_verify_peer: false
	EOF
if [ ${SIGNATURE_VERSION} -ne 4 ]
then
	echo "    signature_version: '${SIGNATURE_VERSION}'" >> config/private.yml
fi

# create empty blobs.yml
touch config/blobs.yml

# proceed download
cd src
[ -x downloadblob.sh ] && . ./downloadblob.sh || exit 666
cd -

# adding all blobs except mongodb ones
for file in $(cat packages/*/spec | grep -Ew "tgz|tar" | awk '{print $2}')
do
  package_name=`echo $file| cut -d"/" -f1`
  if [ ${package_name} != "mongodb" ]
  then	
	  f=`echo $file| cut -d"/" -f2` # with wild characters
	  downloaded_file=`ls src/$f| cut -d"/" -f2`
	  [ "${downloaded_file}" == "" ] && exit 666
	  bosh -e ${ALIAS} add-blob src/${downloaded_file} ${package_name}/${downloaded_file}
  fi
done

bosh -e ${ALIAS} -n upload-blobs

# the go vendor package case ...

# which version of golang is used on git ?
go_git_fingerprint=$(cat packages/golang-1.8-linux/spec.lock \
					| sed -e s/:[[:space:]]*/:/g 			 \
					| grep fingerprint 						 \
					| cut -d":" -f2 )

git clone https://github.com/bosh-packages/golang-release ${ROOT_FOLDER}/golang-release

cd ${ROOT_FOLDER}/golang-release

fingerprint_tag="$(grep -l -r -F ${go_git_fingerprint} releases/ | sed -e 's/^.*\([[0-9]]*\.[[0-9]]*\.[[0-9]]*\).*$/v\1/')"

git checkout ${fingerprint_tag}

cd -

dest_id=$(python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < \
	.final_builds/packages/golang-1.8-linux/index.yml \
	| jq -r '.builds|map(select(.version|contains("'${go_git_fingerprint}'")))[0].blobstore_id')

[ -d .final_builds/packages/golang* ] && rm -rf .final_builds/packages/golang*
[ -d packages/golang* ] && rm -rf packages/golang*  

# reuploading golang

bosh vendor-package golang-1.8-linux ${ROOT_FOLDER}/golang-release

# and now the id is ....
id=$(python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < \
	.final_builds/packages/golang-1.8-linux/index.yml \
	| jq -r '.builds|map(select(.version|contains("'${go_git_fingerprint}'")))[0].blobstore_id')

# appending to the list
echo "$id $dest_id" >> ${ROOT_FOLDER}/to_rename/blob_mv_list.lst || exit 666

cp -rp config/*.yml ${ROOT_FOLDER}/ci || exit 666