#!/usr/bin/env bash

gunicorn --bind 0.0.0.0:5000 \
    --pythonpath /agave-cli/tests/agave_mock_server wsgi \
    --log-file /agave-cli/tests/agave_mock_server.log \
    --capture-output \
    --daemon
