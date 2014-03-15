include Makefile.data

BUNDLE_FILES= \
  ./bsdtar.exe \
  ./wget.exe \
  ./liblzma-5.dll \
  ./yypkg.exe \
  ./sherpa.exe \
  ./win-install.bat \
  ./msys-cygwin-install.sh \
  ./win-builds-switch.sh

BUNDLE_FILES_PATH:=$(subst ./,win-builds-bundle/,$(BUNDLE_FILES))

all:
	@echo "Explicitely state what you want to build: bundle or doc."

bundle win-builds-bundle-$(VERSION).zip: $(BUNDLE_FILES_PATH) Makefile.data
	mkdir -p win-builds-bundle
	for f in $(BUNDLE_FILES); do \
	  if [ -e "$${f}" ] && [ "$${f}" -nt "win-builds-bundle/$${f}" ]; then \
	    if file "$${f}" 2>&1 | grep -q 'ASCII text'; then \
	      sed 's/@@VERSION@@/$(VERSION)/g' "$${f}" > "win-builds-bundle/$${f}"; \
	    else \
	      cp "$${f}" win-builds-bundle; \
	    fi; \
	  fi; \
	done
	zip win-builds-bundle-$(VERSION).zip $(BUNDLE_FILES_PATH)

bundle-upload: win-builds-bundle-$(VERSION).zip
	rsync -avLP $< "$(WEB)/$(VERSION)/"

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

build_packages: build_packages.ml
	ocamlopt -g str.cmxa unix.cmxa build_packages.ml -o build_packages

.PHONY: doc
