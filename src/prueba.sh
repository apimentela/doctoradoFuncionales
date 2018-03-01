#!/bin/bash

echo "$BASH_SOURCE"
cd "${BASH_SOURCE%/*}" #|| true
ls
