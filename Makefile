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

all:
	@echo "Explicitely state what you want to build: bundle or doc."

bundle:
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
	zip win-builds-bundle-$(VERSION).zip $(subst ./,win-builds-bundle/,$(BUNDLE_FILES))

doc doc-upload:
	$(MAKE) -C doc $@

web-upload:
	$(MAKE) -C web $@

.PHONY: doc
