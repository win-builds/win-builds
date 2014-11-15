include Makefile.data

build:
	@ cd build && ocamlbuild -quiet build.byte
	(cd .. && \
		NATIVE_TOOLCHAIN=$(NATIVE_TOOLCHAIN) \
		CROSS_TOOLCHAIN_32=$(CROSS_TOOLCHAIN),$(CROSS_TOOLCHAIN_32) \
		CROSS_TOOLCHAIN_64=$(CROSS_TOOLCHAIN),$(CROSS_TOOLCHAIN_64) \
		WINDOWS_32=$(WINDOWS),$(WINDOWS_32) \
		WINDOWS_64=$(WINDOWS),$(WINDOWS_64) \
			./win-builds/build/build.byte $(VERSION) )

doc doc-upload:
	$(MAKE) -C doc $@

web web-upload:
	$(MAKE) -C web $@

tarballs-upload:
	LOGLEVEL=dbg make WINDOWS= CROSS_TOOLCHAIN= NATIVE= 2>&1 \
	  | sed -n 's; [^ ]\+ -> source=\(.\+/.\+/.\+\);\1; p' > file_list
	rsync -avP --delete-after --files-from=file_list .. $(WEB)/$(VERSION)/tarballs/$$dir/
	rm file_list

installer:
	rm -rf installer
	mkdir -p installer
	export YYPREFIX="$$(pwd)/installer"; \
	yypkg --init; \
	rm -f installer/bin/yypkg; \
	cd ../$(VERSION)/packages/windows_32; \
	for p in dbus*--* fontconfig*--* harfbuzz*--* curl* c-ares* winpthreads* gcc* zlib* win-iconv* gettext* lua* libjpeg* libpng* expat* freetype* fribidi* efl* elementary* dejavu-fonts-ttf* yypkg-$(YYPKG_VERSION)-*; do \
	  yypkg --install "$${p}"; \
	done
	cd installer; \
	find share/fonts/TTF \( -name '*.ttf' \! -name DejaVuSans.ttf \! -name DejaVuSans-Bold.ttf \) -exec rm -rf {} +; \
	find bin -name '*.exe' \! -name 'yypkg*.exe' -exec rm -rf {} +; \
	rm -rf {doc,i686-w64-mingw32,include,info,libexec,man,var}; \
	rm -rf etc/yypkg.d; \
	rm -rf lib/evas/modules/{engines/software_ddraw,loaders,savers}; \
	rm -rf lib/{ethumb,elementary,gcc,cmake,cpp.exe,*.def,pkgconfig,python2.7,efreet,ethumb_client}; \
	find lib \( -name '*.dll.a' -o -name '*.a' \) -exec rm -rf {} +; \
	rm -rf share/elementary/images; \
	rm -rf share/eolian; \
	rm -rf share/{locale,elementary/objects,curl,gettext,aclocal}
	find . -type l -exec rm {} +
	tar cv -C installer --exclude='bin/yypkg_wrapper.exe' . \
	  | xz -8vv > win-builds-$(VERSION).tar.xz
	(cat installer/bin/yypkg_wrapper.exe; \
	  cat win-builds-$(VERSION).tar.xz; \
	  ../yypkg/src/wrapper.native $$(stat --printf='%s' win-builds-$(VERSION).tar.xz)) \
	  > win-builds-$(VERSION).exe

release-upload:
	cd .. && \
	  rsync -avzP \
	  --include='/$(VERSION)' \
	  --include='/$(VERSION)/logs' \
	  --include='/$(VERSION)/packages' \
	  --exclude='memo_pkg' \
	  --exclude='/$(VERSION)/*' \
	  $(VERSION) $(WEB)/

.PHONY: doc web build yypkg installer
