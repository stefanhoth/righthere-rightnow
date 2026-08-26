.DEFAULT_GOAL := help
.PHONY: help deps fmt fmt-check lint test coverage fix ci hooks

## help: list available targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'

## deps: fetch dependencies
deps:
	flutter pub get

## fmt: format sources in place
fmt:
	dart format lib test

## fmt-check: fail if anything is unformatted (does not write)
fmt-check:
	dart format --output=none --set-exit-if-changed lib test

## lint: static analysis, zero tolerance -- infos and warnings are fatal
lint:
	flutter analyze --fatal-infos --fatal-warnings lib test

## test: run tests with randomised ordering
test:
	flutter test --test-randomize-ordering-seed random

## coverage: run tests and write coverage/lcov.info
coverage:
	flutter test --coverage --test-randomize-ordering-seed random

## fix: apply mechanical lint fixes (review the diff -- it edits semantics)
fix:
	dart fix --apply

## ci: everything CI runs, in the same order
ci: deps fmt-check lint test

## hooks: enable the repo's git hooks
hooks:
	git config core.hooksPath .githooks
	@echo "git hooks enabled (core.hooksPath=.githooks)"
