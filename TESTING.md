# Testing

This document contains the code testing guidelines for the `agave-cli`.
It should answer any questions you may have as an aspiring Agave contributor.

## Test suites
The agave cli has two test suites:

* Unit tests - use [bats](https://github.com/sstephenson/bats). They are
  located in [tests](./tests/). Unit tests should be fast and test only their
  own package.

* API integration tests - use [bats](https://github.com/sstephenson/bats) and
  depend on a [mock server](./tests/agave_mock_server). They are located in 
  [tests](./tests/).


## Writing new tests

For more information about how to run tests see
[Bash Automated Testing System](https://github.com/sstephenson/bats).

Some cli commands require user input. To write API integration tests for such
tools we recommend [expect](https://linux.die.net/man/1/expect).

For API integration tests you will have to write an REST API endpoint to mock
the Agave API and register it with the Flask application in
[`agave_mock_server/api.py`](tests/agave_mock_server/agave_mock_server/api.py).

For sample mocked enpoints see
[`agave_mock_server`](tests/agave_mock_server/agave_mock_server).


# Running tests

You are encourage to use the development container to run tests.
To run the tests, first run the developmet container:
```
$ make shell
```

Once you are inside the development container run:
```
$ make tests
```
