# WTF is this CI !!???

## Purpose

the purpose of this document is trying to explain the mongodb-bosh-release CI and the choices made 

## The settings.yml file

This file provide all informations needed by the pipelines

```yaml
---
bosh-server:
  ip:       ***.***.***.*** 
  alias:    ***
  user:     concourse
  password: concourse
  ca:       |
            -----BEGIN CERTIFICATE-----
            ...
            -----END CERTIFICATE-----
  uuid:     461366cc-e110-491a-bc7a-744e33e0df2b

repositories:  
  mongodb:
    uri:        https://github.com/orange-cloudfoundry/mongodb-boshrelease.git
    branch:     main
    username:   ***
    password:   "***"
    git_user:   "***"
    email:      ***@***

  mongodb-compilation:
    uri:        https://github.com/orange-cloudfoundry/mongodb-compilation-boshrelease.git
    branch:     main
    username:   ***
    password:   "***"
    git_user:   "***"
    email:      ***@***

  locks-pool:
    uri:        https://github.com/jraverdy-orange/mongodb-ci-locks-pool.git
    branch:     master
    username:   ***
    password:   "***"
    git_user:   "***"
    email:      ***@*** 

blobstores:

  compilation:
    access_key_id:        ***
    secret_access_key:    ***
    endpoint-url:         https://***.****.***.***
    bucket:               ***
    signature-version:    4
    skip-ssl-validation:  false
    certificate:          |
                          -----BEGIN CERTIFICATE-----
                          ***
                          -----END CERTIFICATE-----

  release:
    access_key_id:        ***
    secret_access_key:    ***
    endpoint-url:         https://***.***.***.***
    bucket:               mongodb-bucket
    signature-version:    4
    skip-ssl-validation:  false
    certificate:          |
                          -----BEGIN CERTIFICATE-----
                          ***
                          -----END CERTIFICATE-----
    http-bucket:          share                          

deployment:
  bootstrap:
    mongodb-version:  3.4.7
    rocksdb-version:  5.7.3
    stemcell:         3468.5  
  
  compilation:
    name:             CI-mongo-comp
    instance-group:   make_archive
    release:          CI-mongo-comp
    network:          concourse-deployment-net
    golang-version:   1.9

  tests:
    name:               CI-mongo
    network:            concourse-deployment-net

    shield:
      core:             https://***.***.***.***
      ca:               |
                        -----BEGIN CERTIFICATE-----
                        ***
                        -----END CERTIFICATE-----
      token:            ***
      tenant:           mongodb-tenant
      storage:          mongo-backups-minio
  
    mongod:
      port:                 27017
      persistent-disk-type: small
      vm-type:              small
      root-username:        ***
      database-name:        CI_db
      collection-name:      CI_datas
      require_ssl:          true
      ca_name:              /internalCA
      ca_cert:              |
                            -----BEGIN CERTIFICATE-----
                            ***
                            -----END CERTIFICATE-----

    credhub:
      ip:       ***.***.***.***
      port:     8844
      username: concourse
      password: concourse

communication:

  mail:
    host:   ***.***.***.***
    port:   "25"
    to:     [ "***@***", "***@***" ]

  http:
    port: 666
    ip: ***.***.***.***

```



## The pipelines chain

Ci is divided into 5 pipelines, some are triggered by modifications on the main releases, some are manually triggered

* **clone blobstore**

  This pipeline allow to copy strictelly the contents of the release's referenced blobstore to another one, on which operator has modification rights. this allow to run the other steps without having deny errors 

* **initialize compilation blobstore**

  It retrieve all needed blobs which are refereced in the `src/downloadblobs.sh` script. then put them on the compilation S3 server.

* **compil-bootstrap-version**

  As we need to test an upgrade from an older mongodb version to the last one, this pipeline allow to compile this old version.  The versions choosen are fixed in the settings file.

* **compilation**

  