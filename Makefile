include Makefile.data


all:
	@echo "Explicitely state what you want to build: bundle or doc."

doc doc-upload:
	$(MAKE) -C doc $@

web-upload:
	$(MAKE) -C web $@

release-upload:
	cd .. && \
	  rsync -avzP \
	  --include='/$(VERSION)' \
	  --include='/$(VERSION)/system.tar.xz' \
	  --include='/$(VERSION)/logs' \
	  --include='/$(VERSION)/packages' \
	  --exclude='/$(VERSION)/*' \
	  1.3.0 $(WEB)/

build:
	@ cd build_packages && ocamlbuild -classic-display build_packages.native
	@ ln -sf build_packages/build_packages.native build

.PHONY: doc web build
