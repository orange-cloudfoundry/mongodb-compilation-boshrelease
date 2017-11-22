
TARGET?=dw
PIPELINE?=get-mongodb-release
SETTINGS?=settings.yml

login:
	fly -t $(TARGET) login

pipeline:
	fly -t $(TARGET) set-pipeline -p $(PIPELINE) --config $(PIPELINE).yml --non-interactive -l $(SETTINGS)

unpause:
	fly -t $(TARGET) unpause-pipeline -p $(PIPELINE)

trigger:
	fly -t $(TARGET) trigger-job -j $(PIPELINE)/check-versions

delete:
	fly -t $(TARGET) dp -p $(PIPELINE) --non-interactive

check:
	fly -t $(TARGET) check-resource --resource $(PIPELINE)/check-versions
