.PHONY: _help help clean clean-build clean-pyc clean-test lint-check lint-fix lint-black-check lint-black-fix lint-flake8-check test test-unit test-integration test-blackbox test-tox install-dev build install
.DEFAULT_GOAL := help

# Ensure make version
ifneq (4.2,$(firstword $(sort $(MAKE_VERSION) 4.2)))
	$(error "Please install GNU Make v4.2+ along with GNU coreutils.")
endif

help: ## Show this help
help: _cmd_prefix = [^_]+
help: _help

_help:
	@awk 'BEGIN {FS = ":.*?## "} \
	/^$(_cmd_prefix)[0-9a-zA-Z_-]+$(_cmd_suffix):.*?##/ \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | \
	sed -E 's/@([0-9a-zA-Z_-]+)/\@\1/g' | \
	sort

PROJECT    = python_package_template
BUILD_DIR  = build
SOURCE_DIR = $(PROJECT)

PYTHON = python

PIP    = $(PYTHON) -m pip
BLACK  = $(PYTHON) -m black
FLAKE8 = $(PYTHON) -m flake8
PYTEST = $(PYTHON) -m pytest
TOX    = $(PYTHON) -m tox
BUILD  = $(PYTHON) -m build

PYTEST_FLAGS = -v --cov=$(SOURCE_DIR)

__env_dir = var/envs/work
__activate_env = source $(__env_dir)/bin/activate &&

$(__env_dir):
	$(PYTHON) -m venv $@
	touch $@

clean: ## remove all development and runtime artifacts
clean: clean/build clean/env clean/pyc clean/test

clean/build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean/env: ## remove environments
	rm -fr .venv/
	rm -fr var/envs/

clean/pyc: ## remove Python artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean/test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint: ## run linters
lint: lint/black lint/flake8

lint/black: $(__env_dir)
lint/black: ## run black linter
	$(__activate_env) $(BLACK) --check --diff --color $(SOURCE_DIR)

lint/flake8: $(__env_dir)
lint/flake8: ## run flake8 linter
	$(__activate_env) $(FLAKE8) --count --show-source --statistics $(SOURCE_DIR)

fmt: ## run formatters
fmt: fmt/black

fmt/black: $(__env_dir)
fmt/black: ## run black formatter
	$(__activate_env) $(BLACK) $(SOURCE_DIR)

test: test/unit test/integration test/blackbox ## run all test suites

test/unit: $(__env_dir)
test/unit: ## run unit test suites
	$(__activate_env) $(PYTEST) $(PYTEST_FLAGS) -m "not (integration or blackbox)"

test/integration: $(__env_dir)
test/integration: ## run integration test suites
	$(__activate_env) $(PYTEST) $(PYTEST_FLAGS) -m "integration"

test/blackbox: clean build install ## run blackbox test suites
	$(__activate_env) $(PYTEST) $(PYTEST_FLAGS) -m "blackbox"

develop: $(__env_dir) ## set up development environment
	$(__activate_env) $(PIP) install --force-reinstall -e ".[dev]"

build: $(__env_dir) ## build wheel package
	$(__activate_env) $(BUILD) --wheel --outdir $(BUILD_DIR)
	ls -l $(BUILD_DIR)
