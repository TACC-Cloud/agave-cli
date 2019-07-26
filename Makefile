PY_SRC != ./hack/find_python_files.sh

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_CLEAN := $(shell echo $(GIT_BRANCH) | sed -e "s/[^[:alnum:]]/-/g")

IMAGE_BASENAME := tapis-cli
DOCKER_ORG ?= tacc
CLI_BRANCH ?= $(GIT_BRANCH)
CLI_VERSION ?= "3.0"
AGAVEPY_BRANCH ?= master

BASE_DOCKERFILE ?= Dockerfile.cosmic
BASE_IMAGE ?= cli-base

PYTEST_DOCKERFILE ?= Dockerfile
PYTEST_DOCKER_IMAGE ?= $(IMAGE_BASENAME)$(if $(GIT_BRANCH_CLEAN),:$(GIT_BRANCH_CLEAN))
PYTEST_DOCKER_MOUNT ?= -v $(CURDIR):/agave-cli

PUBLIC_DOCKER_IMAGE ?= $(DOCKER_ORG)/$(IMAGE_BASENAME):latest
PUBLIC_DOCKERFILE ?= Dockerfile.public
PUBLIC_DOCKER_MOUNT ?= -v $(CURDIR):/work

TESTS_DOCKERFILE_BASENAME ?= Dockerfile.test
TESTS_DOCKER_IMAGE ?= $(DOCKER_ORG)/$(IMAGE_BASENAME)
TESTS_CLI_VERSION ?= "3.1.x"

DOCKERFILE ?= Dockerfile
DOCKER_BUILD_ARGS ?= --force-rm --build-arg AGAVEPY_BRANCH=$(AGAVEPY_BRANCH) --build-arg CLI_BRANCH=$(CLI_BRANCH)
DOCKER_MOUNT_AUTHCACHE ?= -v $(HOME)/.agave:/home/.agave

PYTEST_DOCKER_CLI ?= docker run --rm -it $(PYEST_DOCKER_MOUNT)
PUBLIC_DOCKER_CLI ?= docker run --rm -it $(PUBLIC_DOCKER_MOUNT) $(DOCKER_MOUNT_AUTHCACHE)

.PHONY: authors build docs format shell clean

authors:
	git log --format='%aN <%aE>' | sort -u --ignore-case | grep -v 'users.noreply.github.com' > AUTHORS.txt && \
	git add AUTHORS.txt && \
	git commit AUTHORS.txt -m 'Updating AUTHORS'


build:
	docker build $(DOCKER_BUILD_ARGS) --build-arg CLI_VERSION=$(TEST_CLI_VERSION) -f "$(PYTEST_DOCKERFILE)" -t "$(PYTEST_DOCKER_IMAGE)" .


docs:
	make -C docs html


format: $(PY_SRC)    ## Format source code.
	yapf -i --style=google $^


pytest-shell: build
	$(PYTEST_DOCKER_CLI) -t "$(PYTEST_DOCKER_IMAGE)" bash


clean:
	make -C docs clean

base: base-py3
bases: base-py3 base-py2

base-py3:
	docker build $(DOCKER_BUILD_ARGS) -f $(BASE_DOCKERFILE).py3 -t $(BASE_IMAGE):py3 .

base-py2:
	docker build $(DOCKER_BUILD_ARGS) -f $(BASE_DOCKERFILE).py2 -t $(BASE_IMAGE):py2 .

public-image: public-image-py3
public-images: public-image-py3 public-image-py2

public-image-py3:
	docker build --no-cache $(DOCKER_BUILD_ARGS) --build-arg CLI_VERSION=$(CLI_VERSION) -f $(PUBLIC_DOCKERFILE).py3 -t $(PUBLIC_DOCKER_IMAGE) .

public-image-py2:
	docker build --no-cache $(DOCKER_BUILD_ARGS) --build-arg CLI_VERSION=$(CLI_VERSION) -f $(PUBLIC_DOCKERFILE).py2 -t $(PUBLIC_DOCKER_IMAGE)-py2 .

public-image-release: public-image public-image-py
	docker push $(PUBLIC_DOCKER_IMAGE) ; \
	docker push $(PUBLIC_DOCKER_IMAGE)-py2 .

interactive: public-image

interactive-py3: public-image-p3
	$(PUBLIC_DOCKER_CLI) $(PUBLIC_DOCKER_IMAGE) bash

interactive-py2: public-image-py2
	$(PUBLIC_DOCKER_CLI) $(PUBLIC_DOCKER_IMAGE)-py2 bash

test-image: test-3x-py3
test-images: test-3x-py3 test-3x-py2

test-3x-py3:
	docker build --no-cache $(DOCKER_BUILD_ARGS) --build-arg CLI_VERSION=$(TESTS_CLI_VERSION) -f $(TESTS_DOCKERFILE_BASENAME).py3 -t $(TESTS_DOCKER_IMAGE):test-3x-py3 .

test-3x-py2:
	docker build --no-cache $(DOCKER_BUILD_ARGS) --build-arg CLI_VERSION=$(TESTS_CLI_VERSION) -f $(TESTS_DOCKERFILE_BASENAME).py2 -t $(TESTS_DOCKER_IMAGE):test-3x-py2 .

test-images-release: test-images
	docker push $(TESTS_DOCKER_IMAGE):test-3x-py2 ;\
	docker push $(TESTS_DOCKER_IMAGE):test-3x-py3

shell: shell-py3

shell-py3: test-3x-py3
	$(PUBLIC_DOCKER_CLI) $(TESTS_DOCKER_IMAGE):test-3x-py3 bash

shell-py2: test-3x-py2
	$(PUBLIC_DOCKER_CLI) $(TESTS_DOCKER_IMAGE):test-3x-py2 bash
