#!/usr/bin/env bash

set -eo pipefail

if ! [ -x "$(command -v multi-gitter)" ]; then
  echo 'Error: multi-gitter is not installed.' >&2
  exit 1
fi

if [[ -z ${GITHUB_TOKEN} ]]; then
  echo 'Error: the GITHUB_TOKEN env var is not set.' >&2
  exit 1
fi

set -x

multi-gitter run ./replace.sh --config multi-gitter-config.yaml
