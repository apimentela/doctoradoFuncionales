#!/bin/bash

palabra="$1"

palabra="${palabra%_}"
palabra="${palabra##*_}"

echo "$palabra"

# find /tmp/vocabulario/ -type f -exec ./scripts/vocabulario_output.sh {} >> vocabulario.txt \;
