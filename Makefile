.PHONY: help clean clean-build clean-pyc clean-test lint-check lint-fix lint-black-check lint-black-fix lint-flake8-check test test-unit test-integration test-blackbox test-tox install-dev build install
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

PIP    = python -m pip
BLACK  = python -m black
FLAKE8 = python -m flake8
PYTEST = python -m pytest
TOX    = python -m tox
BUILD  = python -m build

FLAKE8_FLAGS = --count --show-source --statistics
PYTEST_FLAGS = -v --cov={{package}}

BUILD_DIR = build
SOURCE_DIR = {{package}}

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint-check: lint-black-check lint-flake8-check ## run all linters and notify about violations

lint-fix: lint-black-fix ## run all linters and fix the violations

lint-black-check: ## run black and notify about violations
	$(BLACK) --check --diff --color $(SOURCE_DIR)

lint-black-fix: ## run black and fix the violations
	$(BLACK) $(SOURCE_DIR)

lint-flake8-check: ## run flake8 and notify about violations
	$(FLAKE8) $(FLAKE8_FLAGS) $(SOURCE_DIR)

test: test-unit test-integration ## run all test suits

test-unit: ## run unit test suit
	$(PYTEST) $(PYTEST_FLAGS) -m "not (integration or blackbox)"

test-integration: ## run integration test suite
	$(PYTEST) $(PYTEST_FLAGS) -m "integration"

test-blackbox: clean build install ## run blackbox tests
	$(PYTEST) $(PYTEST_FLAGS) -m "blackbox"

test-tox: clean ## run tests using different Python versions with tox
	$(TOX)

install-dev: clean ## install package for development
	$(PIP) install --force-reinstall -e ".[dev]"

build: clean ## build wheel package
	$(BUILD) --wheel --outdir $(BUILD_DIR)
	ls -l $(BUILD_DIR)

install:
	$(PIP) install --force-reinstall $(BUILD_DIR)/*.whla

