#!/usr/bin/env bash

TARGET=localhost
CURL_OPTS="--connect-timeout 15 --silent --show-error --fail"

curl ${CURL_OPTS} "http://${TARGET}:32400/identity" >/dev/null
