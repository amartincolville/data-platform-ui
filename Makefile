.PHONY: buildtype build run stop remove prune

CONF_DIR ?= de-conf

include $(CONF_DIR)/Makefile

IMAGE_NAME ?= "data-platform-ui"
BUILD_TYPE = "docker"
DOCKER_OPTS ?=
DOCKER_PRIVATE_REGISTRY ?= docker-registry-proxy.internal.stuart.com
BUILD_STAGE_NAME ?= "releaser"

USER_ID := $(shell id -u)

buildtype:
	@echo $(BUILD_TYPE)

build:
	@echo "Installing requirements..."
	docker build -t $(IMAGE_NAME) -f Dockerfile $(DOCKER_OPTS) .

run:
	docker-compose -p ${IMAGE_NAME} --env-file local_platform_env_vars.env up -d
	echo "Data Platform UI is now running on http://localhost:8000"

stop:
	docker-compose down
	echo "Data Platform UI stopped"