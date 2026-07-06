SHELL := /bin/zsh
.SHELLFLAGS := -o pipefail -c

.PHONY: build run test

build:
	@if command -v xcbeautify >/dev/null; then swift build 2>&1 | xcbeautify; else swift build; fi

run:
	@swift run song

test:
	@if command -v xcbeautify >/dev/null; then swift test 2>&1 | xcbeautify; else swift test; fi
