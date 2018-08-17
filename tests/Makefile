SRC=$(shell find . -name "*.py"  )

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_CLEAN := $(shell echo $(GIT_BRANCH) | sed -e "s/[^[:alnum:]]/-/g")
DOCKER_IMAGE := agavecli-dev$(if $(GIT_BRANCH_CLEAN),:$(GIT_BRANCH_CLEAN))

DOCKER_BUILD_ARGS ?= --force-rm
DOCKERFILE ?= ../tests.Dockerfile

DOCKER_MOUNT := -v "$(CURDIR)/..":/agave-cli 
DOCKER_FLAGS := docker run --rm -it -p 5000:5000 $(DOCKER_MOUNT)

DOCKER_RUN_AGAVECLI := $(DOCKER_FLAGS) "$(DOCKER_IMAGE)"

.PHONY: authors cli build shell run-tests tests tests-setup clean


authors:
	git log --format='%aN <%aE>' | sort -u --ignore-case | grep -v 'users.noreply.github.com' > AUTHORS.txt && \
	git add AUTHORS.txt && \
	git commit AUTHORS.txt -m 'Updating AUTHORS'

cli:
	cp LICENSE bin/docs/LICENSE && \
	cp DISCLAIMER bin/docs/DISCLAIMER

build: 
	docker build $(DOCKER_BUILD_ARGS) -f "$(DOCKERFILE)" -t "$(DOCKER_IMAGE)" .

shell: build 
	$(DOCKER_RUN_AGAVECLI) bash

run-tests: build
	$(DOCKER_RUN_AGAVECLI) /agave-cli/tests/hack/run-integration-tests.run
	
tests: tests-setup
	bats /agave-cli/tests/integration_tests

tests-setup:
	./hack/setup_agavedb.py
	pip install -e /agave-cli/tests/agave_mock_server
	./hack/serve_agave_mock_server.sh
	./hack/wait-for-it.sh localhost:5000 -- echo "Server is up" || exit 1

clean:
	rm -rf agave_mock_server.log
	rm -rf agave_mock_server/agave_mock_server.egg-info
	rm -rf agave_mock_server/__pycache__/
	rm -rf agave_mock_server/agave_mock_server/__pycache__/
