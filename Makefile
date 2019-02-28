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

# # DOCKER TASKS
# # Build the container
# build: ## Build the container
# 	docker build -t $(APP_NAME) .

# build-nc: ## Build the container without caching
# 	docker build --no-cache -t $(APP_NAME) .

# run: ## Run container on port configured in `config.env`
# 	docker run -i -t --rm --env-file=./config.env -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)


# up: build run ## Run container on port configured in `config.env` (Alias to run)

# stop: ## Stop and remove a running container
# 	docker stop $(APP_NAME); docker rm $(APP_NAME)

# release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

# # Docker publish
# publish: repo-login publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR

# publish-latest: tag-latest ## Publish the `latest` taged container to ECR
# 	@echo 'publish latest to $(DOCKER_REPO)'
# 	docker push $(DOCKER_REPO)/$(APP_NAME):latest

# publish-version: tag-version ## Publish the `{version}` taged container to ECR
# 	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
# 	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# # Docker tagging
# tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

# tag-latest: ## Generate container `{version}` tag
# 	@echo 'create tag latest'
# 	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

# tag-version: ## Generate container `latest` tag
# 	@echo 'create tag $(VERSION)'
# 	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# # HELPERS

# # generate script to login to aws docker repo
# CMD_REPOLOGIN := "eval $$\( aws ecr"
# ifdef AWS_CLI_PROFILE
# CMD_REPOLOGIN += " --profile $(AWS_CLI_PROFILE)"
# endif
# ifdef AWS_CLI_REGION
# CMD_REPOLOGIN += " --region $(AWS_CLI_REGION)"
# endif
# CMD_REPOLOGIN += " get-login --no-include-email \)"

# # login to AWS-ECR
# repo-login: ## Auto login to AWS-ECR unsing aws-cli
# 	@eval $(CMD_REPOLOGIN)

# version: ## Output the current version
# @echo $(VERSION)