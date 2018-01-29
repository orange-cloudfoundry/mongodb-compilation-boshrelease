
TARGET?=dw
PIPELINES_LIST?=mongodb-compilation mongodb-deployment mongodb-clone-blobstore \
				mongodb-compil-strap-version mongodb-initialize-compilation-blobstore
SETTINGS?=settings.yml
delete-team:
	fly -t $(TARGET) destroy-team --team-name mongo --non-interactive
set-team:
	fly -t $(TARGET) set-team --team-name mongo --non-interactive \
	--basic-auth-username mongo \
	--basic-auth-password mongo
login:
	fly -t $(TARGET) login -n mongo -u mongo -p mongo

pipeline:
	for PIPELINE in $(PIPELINES_LIST) ; do \
		fly -t $(TARGET) set-pipeline -p $$PIPELINE --config $$PIPELINE.yml --non-interactive -l $(SETTINGS) ; \
	done	

unpause:
	for PIPELINE in $(PIPELINES_LIST) ; do \
		fly -t $(TARGET) unpause-pipeline -p $$PIPELINE ; \
	done	

trigger:
	fly -t $(TARGET) trigger-job -j mongodb-compilation/check-versions

delete:
	for PIPELINE in $(PIPELINES_LIST) ; do \
		fly -t $(TARGET) dp -p $$PIPELINE --non-interactive ; \
	done

check:
	fly -t $(TARGET) check-resource --resource $(PIPELINE)/check-versions
