# set your docker hub repo name:
REPO="l4rs"

# Get version from git (tag if defined or commit hash)
VERSION=$(shell git describe --abbrev=8 --dirty --always --tags)

# Name equals the current directory name
APP_NAME=$(shell basename $(CURDIR))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@echo "Docker build environment for" $(APP_NAME):
	@echo "  - Build image: make build (build current version image)"
	@echo "  - Latest image: make latest (tags image as latest)"
	@echo "  - Push image: make push (push without latest)"
	@echo "  - Push latest image: make push-latest (publish latest)"
	@echo "  - Test run: make run"
	@echo "  - Version: make version (shows version)"
	@echo ""
	@echo "  - Publish - make publish (builds and publishes all images)" 
.DEFAULT_GOAL := help

version:
	@echo $(VERSION)
build:
	docker build --no-cache -t $(REPO)/$(APP_NAME):$(VERSION) .

run:
	tests/run.sh $(REPO)/$(APP_NAME):$(VERSION) 

push:
	docker push $(REPO)/$(APP_NAME):$(VERSION)

latest:
	docker tag $(REPO)/$(APP_NAME):$(VERSION) $(REPO)/$(APP_NAME):latest
	docker push $(REPO)/$(APP_NAME):latest

publish: version build push latest