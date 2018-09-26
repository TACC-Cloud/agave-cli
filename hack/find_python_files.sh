#!/usr/bin/env bash

find bin/ -type f -print0 | xargs -0 file | awk '$2 == "Python" {print $1}' | sed 's/:$//'
