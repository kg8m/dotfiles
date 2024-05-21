.DEFAULT_GOAL := help
HELP_SEPARATOR := ＠

DENO_CACHE_DIRPATH := .deno/
ALL_DENO_FILES := $$(find . -type f -path '**/.config/vim/denops/**/*.ts' -not -path '*${DENO_CACHE_DIRPATH}*')

.PHONY: help
help:  ## Show help
	@cat $(MAKEFILE_LIST) | \
		grep -E '^[-a-z]+:' | \
		sed -e 's/:.*## /$(HELP_SEPARATOR)/' | \
		column -t -s $(HELP_SEPARATOR)

.PHONY: deno-fmt
deno-fmt:  ## Format deno files
	deno fmt --ignore='${DENO_CACHE_DIRPATH}' ${ALL_DENO_FILES}

.PHONY: deno-fmt-check
deno-fmt-check:  ## Check if deno files are formatted
	deno fmt --ignore='${DENO_CACHE_DIRPATH}' --check ${ALL_DENO_FILES}

.PHONY: deno-lint
deno-lint:  ## Lint deno files
	deno lint --ignore='${DENO_CACHE_DIRPATH}' ${ALL_DENO_FILES}

.PHONY: deno-typecheck
deno-typecheck:  ## Type-check deno files
	deno check ${ALL_DENO_FILES}

.PHONY: deno-cache
deno-cache:  ## Cache deno dependencies
	deno cache ${ALL_DENO_FILES}

.PHONY: deno-update-deps
deno-update-deps:  ## Update deno dependencies
	deno run --allow-all https://deno.land/x/udd/main.ts ${ALL_DENO_FILES}
	make deno-cache
	make deno-fmt

.PHONY: check-all
check-all: deno-fmt-check deno-lint deno-typecheck  ## Check files

.PHONY: all
all: deno-update-deps check-all  ## Update deps and check files
