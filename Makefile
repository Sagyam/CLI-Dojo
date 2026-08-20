# YetiLink CLI Dojo — Makefile
IMAGE_NAME ?= cli-dojo:latest
SEEDS ?= 42 1337 2026 9999 54321

.PHONY: all build run test test-one shellcheck bats-check clean

all: build

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker compose run --rm dojo

# Run a single exercise CI contract inside the container
# Example: make test-one N=00 SEED=42
test-one:
	@if [ -z "$(N)" ]; then echo "Error: N is required. Example: make test-one N=00 SEED=42"; exit 1; fi
	docker run --rm \
		--hostname yetilink-ops-01 \
		-v "$$(pwd)/dojo:/opt/dojo" \
		-v "$$(pwd)/ci:/opt/dojo/ci" \
		-v "$$(pwd)/CHEATSHEET.md:/opt/dojo/CHEATSHEET.md" \
		$(IMAGE_NAME) /opt/dojo/ci/run-exercise-ci.sh $(N) $(if $(SEED),$(SEED),42)

# Run full matrix test suite (all implemented exercises across all 5 seeds)
test:
	@echo "Running CLI Dojo test suite across seeds: $(SEEDS)..."
	@for ex in $$(find dojo/exercises -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort); do \
		id=$$(echo "$$ex" | cut -d'-' -f1); \
		for seed in $(SEEDS); do \
			echo "==> Testing exercise $$id ($$ex) with seed $$seed..."; \
			docker run --rm \
				--hostname yetilink-ops-01 \
				-v "$$(pwd)/dojo:/opt/dojo" \
				-v "$$(pwd)/ci:/opt/dojo/ci" \
				-v "$$(pwd)/CHEATSHEET.md:/opt/dojo/CHEATSHEET.md" \
				$(IMAGE_NAME) /opt/dojo/ci/run-exercise-ci.sh "$$id" "$$seed" || exit 1; \
		done; \
	done
	@echo "✓ All exercise test matrix cells passed!"

# Lint all shell scripts using shellcheck inside container
# Exclude SC2034: library files (e.g. common.sh) define color constants meant for external scripts
shellcheck:
	@echo "Running ShellCheck on all repository shell scripts..."
	docker run --rm -v "$$(pwd):/workspace" -w /workspace $(IMAGE_NAME) \
		shellcheck -e SC2034 \
		entrypoint.sh \
		ci/*.sh \
		dojo/bin/* \
		dojo/lib/*.sh \
		$$(find dojo/exercises -name "*.sh")
	@echo "✓ ShellCheck clean!"

# Syntax check all bats files
bats-check:
	@echo "Verifying BATS test syntax..."
	docker run --rm -v "$$(pwd):/workspace" -w /workspace $(IMAGE_NAME) \
		bash -c 'for f in dojo/exercises/*/grade.bats; do bats --count "$$f" >/dev/null && echo "✓ $$f"; done'
	@echo "✓ Bats syntax check passed!"

clean:
	docker compose down -v 2>/dev/null || true
