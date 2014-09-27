.EXPORT_ALL_VARIABLES:

include ../Makefile.data

OCAMLFIND_DESTDIR := $(abspath deps)
OCAMLPATH := $(abspath deps)
OCAMLFIND_IGNORE_DUPS_IN := $(shell ocamlfind -printconf path)

all yypkg:
	./build_yypkg

install:
	cp -L yypkg-$(YYPKG_VERSION)/src/yypkg.native $${BINDIR:-/usr/local/bin}/yypkg

.PHONY: all yypkg install
