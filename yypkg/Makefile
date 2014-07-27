include ../Makefile.data

YYPKG_TARBALL := yypkg-$(YYPKG_VERSION).tar.xz
FILEUTILS_TARBALL := ocaml-fileutils-$(FILEUTILS_VERSION).tar.gz
ARCHIVE_TARBALL := ocaml-archive-$(ARCHIVE_VERSION).tar.gz
CRYPTOKIT_TARBALL := cryptokit-$(CRYPTOKIT_VERSION).tar.gz
LIBOCAML_TARBALL := libocaml-$(LIBOCAML_VERSION).tar.xz

TARBALLS := $(YYPKG_TARBALL) $(FILEUTILS_TARBALL) $(ARCHIVE_TARBALL) $(CRYPTOKIT_TARBALL) $(LIBOCAML_TARBALL)
DIRS0 := $(TARBALLS:.tar.gz=)
DIRS := $(DIRS0:.tar.xz=)

all: yypkg

$(TARBALLS):
	wget $(YYPKG_FILES)/$@

$(DIRS): $(TARBALLS)
	for file in $?; do tar xf $${file}; done

export YYPKG_SOURCE=$(abspath yypkg-$(YYPKG_VERSION))
export OCAMLFIND_DESTDIR=$(abspath deps)
export OCAMLPATH=$(abspath deps)

CD = \
	cd $(shell find -maxdepth 1 -type d -name '$(1)*')

BUILD_OASIS = \
	$(call CD,$(1)) \
	&& ./configure --prefix "$(OCAMLFIND_DESTDIR)" $(3) \
	&& make \
	&& (make uninstall; ocamlfind remove $(2); make install)

PATCH = \
	patch --verbose -p1 < $(YYPKG_SOURCE)/$(1)

ocaml-fileutils:: $(DIRS)
	$(call CD,ocaml-fileutils) && \
	$(call PATCH,fileutils-symlink-patches/0001-FileUtil-replace-stat.is_link-boolean-with-a-Link-va.patch) && \
	$(call PATCH,fileutils-symlink-patches/0002-FileUtil-symlinks-patch-2.patch)
	$(call BUILD_OASIS,ocaml-fileutils,fileutils)

ocaml-archive:: $(DIRS)
	$(call CD,ocaml-archive) && \
	$(call PATCH,archive-patches/0001-_oasis-make-it-possible-to-not-build-tests-docs-and-.patch) && \
	$(call PATCH,archive-patches/0002-Bind-extract-set_pathname-and-read_open_memory-strin.patch) && \
	$(call PATCH,archive-patches/0003-stubs-bind-archive_entry_-set_-pathname-through-a-ma.patch) && \
	$(call PATCH,archive-patches/0004-Bind-archive_entry_-set_-hard-sym-link-and-archive_e.patch)
	$(call BUILD_OASIS,ocaml-archive,archive,--disable-archivelwt --disable-tests --disable-docs)

cryptokit: $(DIRS)
	$(call BUILD_OASIS,cryptokit,cryptokit)

libocaml: $(DIRS)
	$(call CD,libocaml) && \
	for i in exception option lexing ipv4_address ipv6_address plus uri http; do \
	  (cd libocaml_$i && make && make install) || break \
	done

yypkg: $(DIRS) cryptokit libocaml ocaml-archive ocaml-fileutils
	$(call CD,yypkg) && \
	make

install: yypkg
	$(call CD,yypkg) && \
	cp -L src/yypkg.native /usr/local/bin/yypkg

$(OCAMLFIND_DESTDIR)/stublibs:
	mkdir -p $(OCAMLFIND_DESTDIR)/stublibs

.PHONY: build
