# https://gist.github.com/straight-shoota/275685fcb8187062208c0871318c4a23

DOC_SOURCE   ::= src/**
BUILD_TARGET ::= bin/crylox

# The shards command to use
SHARDS ?= shards
# The crystal command to use
CRYSTAL ?= crystal

SRC_SOURCES ::= $(shell find src -name '*.cr' 2>/dev/null)
LIB_SOURCES ::= $(shell find lib -name '*.cr' 2>/dev/null)
SPEC_SOURCES ::= $(shell find spec -name '*.cr' 2>/dev/null)

.PHONY: build
build: ## Build the application binary
build: $(BUILD_TARGET)

$(BUILD_TARGET): $(SRC_SOURCES) $(LIB_SOURCES) lib
	mkdir -p $(shell dirname $(@))
	$(CRYSTAL) build src/Crylox.cr -o $(@)

.PHONY: run
run: ## Run the application binary
run: build
	$(BUILD_TARGET)

.PHONY: test
test: ## Run the test suite
test: lib
	$(CRYSTAL) spec

.PHONY: format
format: ## Apply source code formatting
format: $(SRC_SOURCES) $(SPEC_SOURCES)
	$(CRYSTAL) tool format src spec

docs: ## Generate API docs
docs: $(SRC_SOURCES) lib
	$(CRYSTAL) docs -o docs $(DOC_SOURCE)

lib: shard.lock
	$(SHARDS) install

shard.lock: shard.yml
	$(SHARDS) update

.PHONY: clean
clean: ## Remove application binary
clean:
	@rm -f $(BUILD_TARGET)

.PHONY: gen_ast
gen_ast: ## Generate Stmt.cr and Expr.cr
gen_ast: src/GenerateAst.cr
	$(CRYSTAL) run src/GenerateAst.cr -Dgenerate_ast_main

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34moptional variables:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+ \?=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
		awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "  \033[36m%s\033[0m\n", $$2}; /^##  / {printf "  %s\n", $$2}'
