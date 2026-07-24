#!/bin/bash

docker run --platform=linux/amd64 -it --rm -v $(pwd):/workspace -w /workspace myenv:latest ./scripts/synth_valid.sh "$1" "$2"