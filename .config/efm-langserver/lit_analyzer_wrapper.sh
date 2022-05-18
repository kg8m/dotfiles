#!/usr/bin/env bash
if ! command -v lit-analyzer > /dev/null; then
  exit 1
fi

if [ ! "${LIT_ANALYZER_AVAILABLE:-}" = "1" ]; then
  exit 1
fi

# Always use the latest Node.js version for lit-analyzer.
export ASDF_NODEJS_VERSION="$(asdf list nodejs | tail -n1)"

filepath="${1:?}"
args=(
  "${filepath}"
  --format list
  --noColor
  --strict
  "${=LIT_ANALYZER_EXTRA_OPTIONS}"
)

lit-analyzer "${args[@]}"
