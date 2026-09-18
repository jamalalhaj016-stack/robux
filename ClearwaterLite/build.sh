#!/bin/sh
# Repack the shaderpack. The zip must have shaders/ at its root.
set -e
cd "$(dirname "$0")"
rm -f ClearwaterLite.zip
zip -r -q ClearwaterLite.zip shaders README.md
echo "built ClearwaterLite.zip"
unzip -l ClearwaterLite.zip | tail -3
