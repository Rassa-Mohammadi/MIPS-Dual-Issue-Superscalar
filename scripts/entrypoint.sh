#!/bin/bash
set -e
python3 /workspace/scripts/fixlogisim.py || true
exec "$@"