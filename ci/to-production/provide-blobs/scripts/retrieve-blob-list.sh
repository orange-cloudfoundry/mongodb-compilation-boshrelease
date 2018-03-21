#!/usr/bin/env sh 

set -ex

ROOT_FOLDER=${PWD}

# retrieve the blobs from compilation blobstore
cd mongodb-bosh-release-patched

mkdir -p ${ROOT_FOLDER}/blobs-list

python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < config/blobs.yml \
| jq -r '.	|to_entries[]
			|select(.key|contains("mongo"))
			|.value.object_id	+":"
							 	+(	.key
							 		|split("/")
							 		|to_entries[]
							 		|select(.key==1)
							 		|.value)
							 	+":"
							 	+.value.sha	' \
> ${ROOT_FOLDER}/blobs-list/blobs.lst
