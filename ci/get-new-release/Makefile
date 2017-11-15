
TARGET?=dw
PIPELINE?=get-mongodb-release
CONFIG?=config.yml

login:
	fly -t $(TARGET) login

pipeline:
	fly -t $(TARGET) set-pipeline -p $(PIPELINE) --config $(PIPELINE).yml --non-interactive -l $(CONFIG)

unpause:
	fly -t $(TARGET) unpause-pipeline -p $(PIPELINE)

trigger:
	fly -t $(TARGET) trigger-job -j $(PIPELINE)/get-mongodb-release

delete:
	fly -t $(TARGET) dp -p $(PIPELINE) --non-interactive