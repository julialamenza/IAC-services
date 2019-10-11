#!/bin/bash
set -e -o pipefail

PACKER_ONLY="amazon-ebs"
PACKER_EXTRA_ARGS="$@"
PACKER_VARS_FILE="$(pwd)/packer.var.json"
PACKER_TEMPLATE="$(jq -r -c .template ${PACKER_VARS_FILE})"
SCRIPT_DIR="$(dirname $(realpath $0))"
BRANCH="develop"
OUTPUT_FILE=""

if [[ -n $1 && $1 != -* && $1 != "local" ]]; then
  if [[ $2 = "-output-file" ]]; then
    OUTPUT_FILE="$(pwd)/packer.out"
    PACKER_EXTRA_ARGS="${@:3}"
  else
    PACKER_EXTRA_ARGS="${@:2}"
  fi
  BRANCH="$1"
fi

if [[ $1 = "local" ]]; then

  PACKER_ONLY="vagrant"
  PACKER_EXTRA_ARGS="${@:2}"

  if [[ $2 != -* ]]; then
    if [[ $3 = "-output-file" ]]; then
      OUTPUT_FILE="$(pwd)/packer.out"
      PACKER_EXTRA_ARGS="${@:4}"
  else
    PACKER_EXTRA_ARGS="${@:3}"
  fi
    BRANCH="$2"
  fi
fi

VERSION="$(echo $BRANCH | sed 's!\/!-!')"

echo "==> packer: Version: ${VERSION}"
echo "==> packer: Branch: ${BRANCH}"
echo "==> packer: Output File: ${OUTPUT_FILE}"
echo "==> packer: Packer Extra Args: ${PACKER_EXTRA_ARGS}"

packer build -force \
  -only="${PACKER_ONLY}" \
  -var-file packer.var.json \
  -var "version=${VERSION}" \
  -var "branch=${BRANCH}" \
  $PACKER_EXTRA_ARGS \
  "${SCRIPT_DIR}/templates/${PACKER_TEMPLATE}.json" | tee -i $OUTPUT_FILE