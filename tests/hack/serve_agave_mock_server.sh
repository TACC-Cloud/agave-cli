#!/usr/bin/env bash

gunicorn --bind 0.0.0.0:5000 \
    --certfile /agave-cli/tests/hack/dummy-cert.pem \
    --keyfile /agave-cli/tests/hack/dummy-key.pem \
    --pythonpath /agave-cli/tests/agave_mock_server wsgi \
    --log-file /agave-cli/tests/agave_mock_server.log \
    --daemon
