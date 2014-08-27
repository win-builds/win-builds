include ../Makefile.data

export OCAMLFIND_DESTDIR := $(abspath deps)
export OCAMLPATH := $(abspath deps)
export OCAMLFIND_IGNORE_DUPS_IN := $(shell ocamlfind -printconf path)

YYPKG_SOURCE := $(abspath yypkg-$(YYPKG_VERSION))
INSTALL_DIRS := $(OCAMLFIND_DESTDIR) $(OCAMLFIND_DESTDIR)/stublibs

all: yypkg

Makefile: ;
../Makefile.data: ;

lo_http := libocaml_http.$(LIBOCAML_VERSION)
lo_uri := libocaml_uri.$(LIBOCAML_VERSION)
lo_plus := libocaml_plus.$(LIBOCAML_VERSION)
lo_ipv6 := libocaml_ipv6_address.$(LIBOCAML_VERSION)
lo_ipv4 := libocaml_ipv4_address.$(LIBOCAML_VERSION)
lo_lexing := libocaml_lexing.$(LIBOCAML_VERSION)
lo_exception := libocaml_exception.$(LIBOCAML_VERSION)
lo_option := libocaml_option.$(LIBOCAML_VERSION)
libocaml := $(lo_http) $(lo_uri) $(lo_plus) $(lo_ipv6) $(lo_ipv4) $(lo_lexing) $(lo_exception) $(lo_option)
fileutils := ocaml-fileutils-$(FILEUTILS_VERSION)
archive := ocaml-archive-$(ARCHIVE_VERSION)
cryptokit := cryptokit-$(CRYPTOKIT_VERSION)
yypkg := yypkg-$(YYPKG_VERSION)

$(INSTALL_DIRS):
	mkdir -p deps/stublibs

tarballs/%:
	mkdir -p tarballs
	cd tarballs && wget $(YYPKG_FILES)/$(subst tarballs/,,$@)

EXTRACT_CD = \
	tar xf tarballs/$(1).tar.?z; \
	cd $(1)

BUILD_OASIS = \
	./configure --prefix "$(OCAMLFIND_DESTDIR)" $(2) \
	&& make \
	&& (make uninstall || true; ocamlfind remove $(1) || true; make install)

PATCH = \
	patch --verbose -p1 < $(YYPKG_SOURCE)/$(1)

MAKE_LIBOCAML = \
	$(call EXTRACT_CD,$(1)) && make && make install

$(fileutils): tarballs/$(fileutils).tar.gz
	$(call EXTRACT_CD,$@) && \
	$(call PATCH,fileutils-symlink-patches/0001-FileUtil-replace-stat.is_link-boolean-with-a-Link-va.patch) && \
	$(call PATCH,fileutils-symlink-patches/0002-FileUtil-symlinks-patch-2.patch) && \
	$(call BUILD_OASIS,fileutils)

$(archive): tarballs/$(archive).tar.gz $(fileutils)
	$(call EXTRACT_CD,$@) && \
	$(call PATCH,archive-patches/0001-_oasis-make-it-possible-to-not-build-tests-docs-and-.patch) && \
	$(call PATCH,archive-patches/0002-Bind-extract-set_pathname-and-read_open_memory-strin.patch) && \
	$(call PATCH,archive-patches/0003-stubs-bind-archive_entry_-set_-pathname-through-a-ma.patch) && \
	$(call PATCH,archive-patches/0004-Bind-archive_entry_-set_-hard-sym-link-and-archive_e.patch) && \
	$(call BUILD_OASIS,archive,--disable-archivelwt --disable-tests --disable-docs)

$(cryptokit): tarballs/$(cryptokit).tar.gz
	$(call EXTRACT_CD,$@) && \
	$(call BUILD_OASIS,cryptokit,)

# I can't manage to make a working pattern rule
$(lo_http): tarballs/$(lo_http).tar.xz $(lo_lexing) $(lo_option) $(lo_plus) $(lo_uri)
	$(call MAKE_LIBOCAML,$@)
$(lo_uri): tarballs/$(lo_uri).tar.xz $(lo_exception) $(lo_ipv4) $(lo_ipv6) $(lo_lexing) $(lo_option) $(lo_plus)
	$(call MAKE_LIBOCAML,$@)
$(lo_plus): tarballs/$(lo_plus).tar.xz $(lo_exception)
	$(call MAKE_LIBOCAML,$@)
$(lo_ipv6): tarballs/$(lo_ipv6).tar.xz $(lo_exception) $(lo_lexing)
	$(call MAKE_LIBOCAML,$@)
$(lo_ipv4): tarballs/$(lo_ipv4).tar.xz $(lo_exception) $(lo_option)
	$(call MAKE_LIBOCAML,$@)
$(lo_lexing): tarballs/$(lo_lexing).tar.xz $(lo_exception)
	$(call MAKE_LIBOCAML,$@)
$(lo_exception): tarballs/$(lo_exception).tar.xz
	$(call MAKE_LIBOCAML,$@)
$(lo_option): tarballs/$(lo_option).tar.xz
	$(call MAKE_LIBOCAML,$@)

yypkg yypkg-no-gui: tarballs/$(yypkg).tar.xz $(cryptokit) $(archive) $(fileutils) $(libocaml)
	$(call EXTRACT_CD,$(yypkg)) && \
	make $@

install: yypkg
	cd yypkg-$(YYPKG_VERSION) && \
	cp -L src/yypkg.native /usr/local/bin/yypkg

$(fileutils) $(archive) $(cryptokit) $(libocaml): $(INSTALL_DIRS)

.PHONY: yypkg yypkg-no-gui install
