CRYSTAL=crystal
CRFLAGS=

run:
	$(CRYSTAL) $(CRFLAGS) src/Crylox.cr

build:
	$(CRYSTAL) build $(CRFLAGS) src/Crylox.cr

gen_ast:
	$(CRYSTAL) $(CRFLAGS) src/GenerateAst.cr

test_ast:
	$(CRYSTAL) $(CRFLAGS) src/AstPrinter.cr

.PHONY: run build gen_ast test_ast
