#!/usr/bin/env zsh
# Always use the latest Node.js version for lit-analyzer.
export MISE_NODE_VERSION="latest"

if ! command -v lit-analyzer > /dev/null; then
  exit 1
fi

if [ ! "${USE_LIT_ANALYZER:-}" = "1" ]; then
  exit 1
fi

filepath="${1:?}"
args=(
  "${filepath}"
  --format list
  --noColor
  --strict
)

if [ -n "${LIT_ANALYZER_EXTRA_OPTIONS:-}" ]; then
  args+=("${=LIT_ANALYZER_EXTRA_OPTIONS}")
fi

lit-analyzer "${args[@]}"
