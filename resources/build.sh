#!/usr/bin/bash
DIR="$(cd "$(dirname "$0")/../" && pwd)"
BUILD="$DIR/cpp"
BACK="$DIR/back"
FRONT="$DIR/front"

pnpm -C "$BACK" install
pnpm -C "$FRONT" install

mkdir -p "$BUILD/build"
cmake -S "$BUILD" -B "$BUILD/build"
cmake --build "$BUILD/build"
