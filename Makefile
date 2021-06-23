# Analyze the given Python modules and compute Cyclomatic Complexity
cc_json = "$(shell radon cc --min B src --json)"
# Analyze the given Python modules and compute the Maintainability Index
mi_json = "$(shell radon mi --min B src --json)"

files = `find ./pyruler ./tests -name "*.py"`
files_tests = `find  ./tests -name "*.py"`

help: ## Display this help screen.
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

lint: ## Run Pylint checks on the project.
	@pylint $(files)

fmt: ## Format all project files.
	@isort pyruler tests
	@yapf pyruler tests -r -i -vv

test: ## Run unit testings.
	@mamba $(files_tests) --format documentation --enable-coverage

cover: test ## Execute coverage analysis for executed tests
	@coverage report --omit '*virtualenvs*','*tests*'

cover_html: test ## Execute coverage analysis for executed test and show it as HTML
	@coverage html --omit '*virtualenvs*','*tests*' && firefox htmlcov/index.html

install: ## Install project dependencies.
	@poetry install

venv: ## Create new virtual environment. Run `source venv/bin/activate` after this command to enable it.
	@poetry shell

complexity: ## Run radon complexity checks for maintainability status.
	@echo "Complexity check..."

ifneq ($(cc_json), "{}")
	@echo
	@echo "Complexity issues"
	@echo "-----------------"
	@echo $(cc_json)
endif

ifneq ($(mi_json), "{}")
	@echo
	@echo "Maintainability issues"
	@echo "----------------------"
	@echo $(mi_json)
endif

ifneq ($(cc_json), "{}")
	@echo
	exit 1
else
ifneq ($(mi_json), "{}")
	@echo
	exit 1
endif
endif

	@echo "OK"
.PHONY: complexity