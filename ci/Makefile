
TARGET?=dw
PIPELINES_LIST?=mongodb-compilation mongodb-deployment
SETTINGS?=settings.yml

login:
	fly -t $(TARGET) login

pipeline:
	for PIPELINE in $(PIPELINES_LIST) ; do \
		fly -t $(TARGET) set-pipeline -p $$PIPELINE --config $$PIPELINE.yml --non-interactive -l $(SETTINGS) ; \
	done	

unpause:
	for PIPELINE in $(PIPELINES_LIST) ; do \
		fly -t $(TARGET) unpause-pipeline -p $$PIPELINE ; \
	done	

trigger:
	fly -t $(TARGET) trigger-job -j $(PIPELINE)/check-versions

delete:
	fly -t $(TARGET) dp -p $(PIPELINE) --non-interactive

check:
	fly -t $(TARGET) check-resource --resource $(PIPELINE)/check-versions
