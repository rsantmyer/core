#!/usr/bin/env bash
set -euo pipefail

: > env.sql

for dir in ../*/; do
    name="$(basename "$dir")"

    # Skip directories that are not tracked by this git repo
    if hash="$(git log -1 --pretty=format:%H -- "$dir" 2>/dev/null)" && [[ -n "$hash" ]]; then
        # SQL*Plus substitution variables are easier to use consistently in uppercase
        var_name="$(printf '%s' "$name" | tr '[:lower:]-' '[:upper:]_')"

        printf "DEFINE %s = %s\n" "$var_name" "$hash" >> env.sql
    fi
done