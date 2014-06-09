include Makefile.data

build:
	@ cd build_packages && ocamlbuild -classic-display build_packages.byte
	@ (cd .. && \
		NATIVE_TOOLCHAIN=$(NATIVE_TOOLCHAIN) \
		CROSS_TOOLCHAIN=$(CROSS_TOOLCHAIN) \
		WINDOWS_32=$(WINDOWS),$(WINDOWS_32) \
		WINDOWS_64=$(WINDOWS),$(WINDOWS_64) \
			./win-builds/build_packages/build_packages.byte $(VERSION) )

doc doc-upload:
	$(MAKE) -C doc $@

web-version-agnostic-upload web-version-specific-upload:
	$(MAKE) -C web $(patsubst web-%,%,$@)

release-upload:
	cd .. && \
	  rsync -avzP \
	  --include='/$(VERSION)' \
	  --include='/$(VERSION)/logs' \
	  --include='/$(VERSION)/packages' \
	  --exclude='memo_pkg' \
	  --exclude='/$(VERSION)/*' \
	  $(VERSION) $(WEB)/

.PHONY: doc web build
