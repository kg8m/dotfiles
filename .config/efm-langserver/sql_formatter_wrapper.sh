#!/usr/bin/env bash
options=(
  --uppercase
)

# Specify `mysql` as default language because formatted query gets invalid if it contains backticks.
# cf. https://github.com/zeroturnaround/sql-formatter/issues/139
options+=(
  --language "${SQL_LANGUAGE:-mysql}"
)

sql-formatter "${options[@]}"
