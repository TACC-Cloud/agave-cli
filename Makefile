PY_SRC != ./hack/find_python_files.sh

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_CLEAN := $(shell echo $(GIT_BRANCH) | sed -e "s/[^[:alnum:]]/-/g")
DOCKER_IMAGE := agave-cli$(if $(GIT_BRANCH_CLEAN),:$(GIT_BRANCH_CLEAN))
PUBLIC_DOCKER_IMAGE := tacc/tapis-cli:latest

DOCKER_BUILD_ARGS ?= --force-rm
DOCKERFILE ?= Dockerfile

DOCKER_MOUNT_AUTHCACHE := -v $(HOME)/.agave:/home/.agave
DOCKER_MOUNT := -v $(CURDIR):/agave-cli
DOCKER_FLAGS := docker run --rm -it $(DOCKER_MOUNT)

DOCKER_RUN_AGAVECLI := $(DOCKER_FLAGS) "$(DOCKER_IMAGE)"

CLI_BRANCH ?= $(GIT_BRANCH)
CLI_VERSION ?= "3.1.y"
AGAVEPY_BRANCH ?= master
DOCKER_ORG ?= tacc

.PHONY: authors build docs format shell clean


authors:
	git log --format='%aN <%aE>' | sort -u --ignore-case | grep -v 'users.noreply.github.com' > AUTHORS.txt && \
	git add AUTHORS.txt && \
	git commit AUTHORS.txt -m 'Updating AUTHORS'


build:
	docker build $(DOCKER_BUILD_ARGS) -f "$(DOCKERFILE)" -t "$(DOCKER_IMAGE)" .


docs:
	make -C docs html


format: $(PY_SRC)    ## Format source code.
	yapf -i --style=google $^


shell: build
	$(DOCKER_RUN_AGAVECLI) bash


clean:
	make -C docs clean

public-image:
	docker build $(DOCKER_BUILD_ARGS) -f Dockerfile.public -t $(DOCKER_ORG)/tapis-cli:latest .

public-image-py2:
	docker build $(DOCKER_BUILD_ARGS) -f Dockerfile.public.py2 -t $(DOCKER_ORG)/tapis-cli:python2 .

interactive: public-image
	docker run --rm -it $(DOCKER_MOUNT) $(DOCKER_MOUNT_AUTHCACHE) $(PUBLIC_DOCKER_IMAGE) bash

interactive-py2: public-image
	docker run --rm -it $(DOCKER_MOUNT) $(DOCKER_MOUNT_AUTHCACHE) $(DOCKER_ORG)/tapis-cli:python2 bash
	docker build $(DOCKER_BUILD_ARGS)  -f Dockerfile.public -t $(DOCKER_ORG)/tapis-cli:latest .

test-images: test-image-3x-py3 test-image-3x-py2

test-image-3x-py3:
	docker build -f Dockerfile.test.py3 -t $(DOCKER_ORG)/tapis-cli:test-3x-py3 \
	--build-arg AGAVEPY_BRANCH=$(AGAVEPY_BRANCH) \
	--build-arg CLI_VERSION=$(CLI_BRANCH) .

test-image-3x-py2:
	docker build -f Dockerfile.test.py2 -t $(DOCKER_ORG)/tapis-cli:test-3x-py2 \
	--build-arg AGAVEPY_BRANCH=$(AGAVEPY_BRANCH) \
	--build-arg CLI_VERSION=$(CLI_BRANCH) .

test-images-push: test-images
	docker push $(DOCKER_ORG)/tapis-cli:test-3x-py2 ;\
	docker push $(DOCKER_ORG)/tapis-cli:test-3x-py3
