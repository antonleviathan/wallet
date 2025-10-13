# Makefile
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

.PHONY: build
build:
	@echo "Running compat check..."
	@out="$$(bash utils/compat.sh)"; \
	if [[ -z "$$out" ]]; then \
		echo "Compat produced no output; proceeding to build"; \
		bash utils/build.sh; \
	else \
		echo "Compat produced output; not building."; \
		printf '%s\n' "$$out"; \
		exit 1; \
	fi
