include ../Makefile.data

export LIBRARY_PATH:=$(PREFIX)/lib:$(LIBRARY_PATH)
export C_INCLUDE_PATH:=$(PREFIX)/include:$(C_INCLUDE_PATH)

PATCHES := $(shell pwd)/patches

DOWNLOAD_AND_EXTRACT = \
	rm -rf "$(1)" \
	&& mkdir -p tarballs \
	&& if ! [ -e "tarballs/$(1).$(2)" ]; then \
		(cd tarballs && curl "$(YYPKG_FILES)/$(1).$(2)" > "$(1).$(2)") \
	fi \
	&& (tar xzf "tarballs/$(1).$(2)" \
	  || (xz -d < "tarballs/$(1).$(2)" | tar xf - ) \
	  || tar xjf "tarballs/$(1).$(2)")


BUILD_AUTOTOOLS = \
	cd $(1)-$(2) \
	&& ./configure --prefix=$(PREFIX) $(3) \
	&& gmake -j4 \
	&& gmake install

BUILD_OASIS = \
	cd $(1)-$(2) \
	&& ocaml setup.ml -configure $(3) \
	&& ocaml setup.ml -build -j 4 \
	&& ocaml setup.ml -install

P = patch --verbose -p1 < "$(PATCHES)/$(1).patch"

all: coreutils make sed findutils patch tar bash libarchive yypkg

xz:
	$(call DOWNLOAD_AND_EXTRACT,xz-$(XZ_VERSION),tar.bz2)
	$(call BUILD_AUTOTOOLS,xz,$(XZ_VERSION),)

coreutils: xz
	$(call DOWNLOAD_AND_EXTRACT,coreutils-$(COREUTILS_VERSION),tar.xz)
	export FORCE_UNSAFE_CONFIGURE=1; \
	$(call BUILD_AUTOTOOLS,coreutils,$(COREUTILS_VERSION),--without-gmp)

make:
	$(call DOWNLOAD_AND_EXTRACT,make-$(MAKE_VERSION),tar.bz2)
	$(call BUILD_AUTOTOOLS,make,$(MAKE_VERSION),)

findutils: xz
	$(call DOWNLOAD_AND_EXTRACT,findutils-$(FINDUTILS_VERSION),tar.xz)
	$(call BUILD_AUTOTOOLS,findutils,$(FINDUTILS_VERSION),)

sed: xz
	$(call DOWNLOAD_AND_EXTRACT,sed-$(SED_VERSION),tar.xz)
	$(call BUILD_AUTOTOOLS,sed,$(SED_VERSION),)

bash:
	$(call DOWNLOAD_AND_EXTRACT,bash-$(BASH_VERSION),tar.gz)
	$(call BUILD_AUTOTOOLS,bash,$(BASH_VERSION),)

tar: xz
	$(call DOWNLOAD_AND_EXTRACT,tar-$(TAR_VERSION),tar.xz)
	export FORCE_UNSAFE_CONFIGURE=1; \
	$(call BUILD_AUTOTOOLS,tar,$(TAR_VERSION),)

patch:
	$(call DOWNLOAD_AND_EXTRACT,patch-$(PATCH_VERSION),tar.bz2)
	$(call BUILD_AUTOTOOLS,patch,$(PATCH_VERSION),)

libarchive: xz
	$(call DOWNLOAD_AND_EXTRACT,libarchive-$(LIBARCHIVE_VERSION),tar.gz)
	$(call BUILD_AUTOTOOLS,libarchive,$(LIBARCHIVE_VERSION),)

ocaml: make xz
	$(call DOWNLOAD_AND_EXTRACT,ocaml-$(OCAML_VERSION),tar.xz)
	(cd ocaml-$(OCAML_VERSION) \
		&& ./configure -no-debugger -prefix $(PREFIX) \
		&& gmake world.opt \
		&& gmake install)

findlib: ocaml
	$(call DOWNLOAD_AND_EXTRACT,findlib-$(FINDLIB_VERSION),tar.gz)
	(cd findlib-$(FINDLIB_VERSION) \
		&& ./configure -no-camlp4 \
		&& gmake \
		&& gmake install)

libocaml: ocaml findlib xz
	for s in exception option lexing plus ipv4_address ipv6_address uri http; do \
		$(call DOWNLOAD_AND_EXTRACT,libocaml_$${s}.$(LIBOCAML_VERSION),tar.xz) \
		&& sed -i '/-w @a-4-6-7-9-23-26-27-29-41/ s/@//' \
			libocaml_$${s}.$(LIBOCAML_VERSION)/lib/libocaml/make/GNUmakefile; \
	done
	cp post-ocamllex libocaml_lexing.$(LIBOCAML_VERSION)/src
	for s in exception option lexing plus ipv4_address ipv6_address uri http; do \
		(cd libocaml_$${s}.$(LIBOCAML_VERSION) && gmake && gmake install); \
	done

ocaml-fileutils: ocaml findlib
	ocamlfind remove fileutils
	$(call DOWNLOAD_AND_EXTRACT,ocaml-fileutils-$(FILEUTILS_VERSION),tar.gz)
	cd ocaml-fileutils-$(FILEUTILS_VERSION) \
	&& $(call P,fileutils/0001-FileUtil-replace-stat.is_link-boolean-with-a-Link-va) \
	&& $(call P,fileutils/0002-FileUtil-symlinks-patch-2)
	$(call BUILD_OASIS,ocaml-fileutils,$(FILEUTILS_VERSION),)

ocaml-archive: ocaml findlib ocaml-fileutils libarchive
	ocamlfind remove archive
	$(call DOWNLOAD_AND_EXTRACT,ocaml-archive-$(ARCHIVE_VERSION),tar.gz)
	cd ocaml-archive-$(ARCHIVE_VERSION) \
	&& $(call P,archive/0001-_oasis-make-it-possible-to-not-build-tests-docs-and-) \
	&& $(call P,archive/0002-Bind-extract-set_pathname-and-read_open_memory-strin) \
	&& $(call P,archive/0003-stubs-bind-archive_entry_-set_-pathname-through-a-ma) \
	&& $(call P,archive/0004-Bind-archive_entry_-set_-hard-sym-link-and-archive_e) \
	&& $(call P,archive/0001-stubs-ARCHIVE_EXTRACT_-MAC_METADATA-NO_HFS_COMPRESSI)
	$(call BUILD_OASIS,ocaml-archive,$(ARCHIVE_VERSION),--disable-archivelwt --disable-tests --disable-docs)

cryptokit: ocaml findlib
	ocamlfind remove cryptokit
	$(call DOWNLOAD_AND_EXTRACT,cryptokit-$(CRYPTOKIT_VERSION),tar.gz)
	$(call BUILD_OASIS,cryptokit,$(CRYPTOKIT_VERSION),)

yypkg: ocaml findlib libocaml ocaml-fileutils ocaml-archive cryptokit xz
	$(call DOWNLOAD_AND_EXTRACT,yypkg-$(YYPKG_VERSION),tar.xz)
	cd yypkg-$(YYPKG_VERSION) && gmake yypkg-no-gui
	cp -L yypkg-$(YYPKG_VERSION)/src/yypkg.native $(PREFIX)/bin/yypkg

.PHONY: coreutils make ocaml findlib sed findutils yypkg
