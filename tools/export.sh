#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

ROOT_DIR=$(git rev-parse --show-toplevel)
EXPORT_DIR="$ROOT_DIR/git-export"

rm -Rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"
git archive HEAD | tar -x -C "$EXPORT_DIR" src
open -a "SLADE" "$EXPORT_DIR/src/"
echo "Please use SLADE to export a PK3."
