#!/bin/bash
set -e
cd `dirname $0`

echo "Use clang-format: $(clang-format --version)"

set -x

for SOURCE in $(ls -1 *.cc); do
  clang-format -i $SOURCE
done
for SOURCE in $(ls -1 *.h); do
  clang-format -i $SOURCE
done
