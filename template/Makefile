.DEFAULT_GOAL := help
SHELL := /bin/bash

help: ## Show targets
	@grep -hE '^[a-z0-9-]+:.*?## ' $(MAKEFILE_LIST) | awk -F':.*?## ' '{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Install all deps + browsers + hooks
	uv sync --locked || uv sync
	pnpm install --frozen-lockfile || pnpm install
	pnpm exec playwright install --with-deps chromium
	bash .claude/hooks/install.sh
	pre-commit install || true

fmt: ## Format everything
	ruff format .
	pnpm exec prettier --write .

lint: ## Lint + typecheck (blocking)
	ruff check .
	mypy --strict src
	pnpm exec eslint .
	pnpm exec tsc --noEmit

test: ## Unit + integration
	pytest -q --cov=src --cov-report=term-missing
	pnpm exec vitest run

e2e: ## Playwright E2E + axe at 3 viewports
	pnpm exec playwright test

design: ## Lint Design.md tokens + regenerate Tailwind theme
	npx -y @google/design.md lint Design.md
	npx -y @google/design.md export --format css-tailwind Design.md > src/styles/tokens.css
	npx -y @google/design.md export --format json-tailwind Design.md > tailwind.tokens.json

design-check: ## Lint Design.md only (CI-safe, no writes)
	npx -y @google/design.md lint --format json Design.md

sec: ## SAST + SCA + secrets
	gitleaks detect --no-banner --redact
	bandit -q -r src
	pip-audit || uv run pip-audit
	pnpm audit --audit-level=high
	semgrep --config=auto --error --quiet src || true

sbom: ## Generate CycloneDX SBOM
	cyclonedx-py environment -o sbom-python.json
	pnpm exec cyclonedx-npm --output-file sbom-node.json

ci: lint design-check test sec e2e ## Everything CI runs

tokens: ## Token consumption report
	@python3 scripts/token_report.py

clean: ## Remove build + cache artifacts
	rm -rf .pytest_cache .mypy_cache .ruff_cache dist build node_modules/.vite

.PHONY: help setup fmt lint design design-check test e2e sec sbom ci tokens clean
