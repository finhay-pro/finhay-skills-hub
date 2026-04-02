#!/usr/bin/env bash
exec node "$(dirname "$0")/write-request.js" "$@"
