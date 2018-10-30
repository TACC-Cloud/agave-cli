PY_SRC != ./hack/find_python_files.sh

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_CLEAN := $(shell echo $(GIT_BRANCH) | sed -e "s/[^[:alnum:]]/-/g")
DOCKER_IMAGE := agave-cli$(if $(GIT_BRANCH_CLEAN),:$(GIT_BRANCH_CLEAN))

DOCKER_BUILD_ARGS ?= --force-rm
DOCKERFILE ?= Dockerfile

DOCKER_MOUNT := -v $(CURDIR):/agave-cli
DOCKER_FLAGS := docker run --rm -it $(DOCKER_MOUNT)

DOCKER_RUN_AGAVECLI := $(DOCKER_FLAGS) "$(DOCKER_IMAGE)"


.PHONY: authors build docs format shell tests tests-setup clean


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


tests: tests-setup
	bats /agave-cli/tests/integration_tests                                     


tests-setup:
	./tests/hack/setup_agavedb.py
	pip install -e /agave-cli/tests/agave_mock_server
	./tests/hack/serve_agave_mock_server.sh
	./tests/hack/wait-for-it.sh localhost:5000 -- echo "Server is up" || exit 1


clean:
	make -C docs clean
	rm -rf tests/tests_results.tap
	rm -rf tests/agave_mock_server.log
	rm -rf tests/agave_mock_server/agave_mock_server.egg-info
	rm -rf tests/agave_mock_server/__pycache__/
	rm -rf tests/agave_mock_server/agave_mock_server/__pycache__/
