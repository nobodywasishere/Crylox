CRYSTAL=crystal
CRFLAGS=

run:
	$(CRYSTAL) run $(CRFLAGS) -D crylox_main src/Crylox.cr

run_all: run_print run_var run_scope

run_print:
	$(CRYSTAL) run $(CRFLAGS) -D crylox_main src/Crylox.cr -- tests/print.lox

run_var:
	$(CRYSTAL) run $(CRFLAGS) -D crylox_main src/Crylox.cr -- tests/var.lox

run_scope:
	$(CRYSTAL) run $(CRFLAGS) -D crylox_main src/Crylox.cr -- tests/scope.lox

build:
	$(CRYSTAL) build $(CRFLAGS) src/Crylox.cr

gen_ast:
	./src/GenerateAst.cr

test_ast:
	./src/AstPrinter.cr

.PHONY: run run_print run_var build gen_ast test_ast
