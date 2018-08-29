#!/usr/bin/env bash

docker run --rm -v "$PWD":/agave-cli agavecli-dev /agave-cli/tests/hack/run-integration-tests.run
