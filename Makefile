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

INSTALLER_TAR = \
  echo "Extracting $${p}"; \
  tar xf "$${p}" -C "$${INSTALLER}" --strip-components=1 --wildcards '$(1)'

installer:
	rm -rf installer
	mkdir -p installer
	INSTALLER="$$(pwd)/installer"; \
	cd ../$(VERSION)/packages/windows_32; \
	for p in dbus*--* fontconfig*--* harfbuzz*--* curl* c-ares* winpthreads* gcc* zlib* win-iconv* gettext* lua* libjpeg* libpng* expat* freetype* fribidi*; do \
		$(call INSTALLER_TAR,windows_32/bin/*.dll); \
	done; \
	for p in efl* elementary* dejavu-fonts-ttf*; do \
		$(call INSTALLER_TAR,); \
	done; \
	for p in yypkg*; do \
	  $(call INSTALLER_TAR,windows_32/bin/*.exe); \
	done
	find installer/share/fonts/TTF \( -name '*.ttf' \! -name DejaVuSans.ttf \! -name DejaVuSans-Bold.ttf \) -exec rm -rf {} +
	cp -aL /opt/windows_32/etc/fonts/* installer/etc/fonts/
	find installer/bin -name '*.exe' \! -name 'yypkg.exe' -exec rm -rf {} +
	rm -rf installer/doc
	rm -rf installer/include
	find installer/lib -name '*.dll.a' -exec rm -rf {} +
	rm -rf installer/share/elementary/images
	rm -rf installer/share/eolian
	mv installer/bin/yypkg.exe installer/bin/yypkg-$(VERSION).exe
	tar c -C installer . | xz -1vv > win-builds-$(VERSION).tar.xz

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
