#!/usr/bin/bash
DIR="$(cd "$(dirname "$0")/../" && pwd)"
cd "$DIR"

mkdir -p tmp
touch tmp/tmp.png

mkdir -p back/uploads

cleanup() {
  jobs -p | xargs -r kill
}
trap cleanup EXIT INT TERM

pnpm -C back dev &
pnpm -C front dev &

wait
