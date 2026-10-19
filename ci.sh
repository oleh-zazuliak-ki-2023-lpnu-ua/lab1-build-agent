#!/usr/bin/env bash
# Configure, build, test and package the project (Linux/macOS)
set -euo pipefail
cd "$(dirname "$0")"

BUILD_DIR=build
DIST_DIR=dist

echo "== Configure =="
cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release

echo "== Build =="
cmake --build "$BUILD_DIR" --config Release --parallel

echo "== Test =="
ctest --test-dir "$BUILD_DIR" -C Release --output-on-failure

echo "== Package =="
mkdir -p "$DIST_DIR"
cp "$BUILD_DIR/hello" "$DIST_DIR/hello"

echo "== Smoke test =="
"$DIST_DIR/hello"

echo "CI: SUCCESS"
