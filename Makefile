include Makefile.data

build:
	@ cd build && ocamlbuild -quiet build.byte
	(cd .. && \
		NATIVE_TOOLCHAIN=$(NATIVE_TOOLCHAIN) \
		CROSS_TOOLCHAIN_32=$(CROSS_TOOLCHAIN),$(CROSS_TOOLCHAIN_32) \
		CROSS_TOOLCHAIN_64=$(CROSS_TOOLCHAIN),$(CROSS_TOOLCHAIN_64) \
		WINDOWS_32=$(WINDOWS),$(WINDOWS_32) \
		WINDOWS_64=$(WINDOWS),$(WINDOWS_64) \
			./win-builds/build/build.byte $(VERSION_DEV) )

doc doc-upload:
	$(MAKE) -C doc $@

web web-upload:
	$(MAKE) -C web $@

tarballs-upload:
	LOGLEVEL=inf make WINDOWS= CROSS_TOOLCHAIN= NATIVE= 2>&1 \
	  | sed -n 's; [^ ]\+ -> source=\(.\+/.\+/.\+\);\1; p' > file_list
	rsync -avP --delete-after --files-from=file_list .. $(WEB)/$(VERSION_DEV)/tarballs/$$dir/
	rm file_list

release-upload:
	cd .. && \
	  rsync -avzP \
	  --include='/$(VERSION_STABLE)' \
	  --include='/$(VERSION_STABLE)/logs' \
	  --include='/$(VERSION_STABLE)/packages' \
	  --exclude='memo_pkg' \
	  --exclude='/$(VERSION_STABLE)/*' \
	  $(VERSION_STABLE) $(WEB)/

.PHONY: doc web build yypkg
