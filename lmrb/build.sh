#!/bin/bash
set -o pipefail

mkdir -p build
swiftc -O -parse-as-library -emit-library -emit-module -module-name LMRB \
  -emit-objc-header-path build/LMRB \
  -Xlinker -install_name \
  -Xlinker @rpath/liblmrb.dylib \
  runtime.swift \
  -o build/liblmrb.dylib
nm -gU build/liblmrb.dylib
