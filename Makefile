include Makefile.data

all:
	@echo "Nothing to build besides the doc."
	true

doc doc-upload:
	$(MAKE) -C doc $@

.PHONY: doc
