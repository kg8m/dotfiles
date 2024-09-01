#!/usr/bin/env bash
if ! command -v erb > /dev/null; then
  exit 1
fi

# Don’t check if on Rails project because some valid syntaxes extended by Erubi are detected as invalid by `erb` command.
if [ -d "app" ] && [ -f "config/environment.rb" ]; then
  exit 0
fi

# Always show errors on the first line because converted Ruby code doesn’t match the original ERB code.
erb -x -T - -P | ruby -c 2>&1 1> /dev/null | sd '^-:' '1:'
