all:
	@echo "Nothing to build besides the doc."
	true

doc:
	$(MAKE) -C doc doc

.PHONY: doc
