include ../Makefile.data

DOCS:=packaging msys-cygwin linux
DOCS_TXT:=$(DOCS:%=%.txt)
DOCS_HTML:=$(DOCS:%=%.html)

version.config: ../Makefile.data Makefile
	echo '[blockdef-listing]' > $@
	echo 'subs=specialcharacters,callouts,replacements' >> $@
	echo '[replacements]' >> $@
	echo '@@VERSION@@=$(VERSION)' >> $@

%.html: %.txt version.config
	a2x -f xhtml \
	  --stylesheet="docbook-xsl.css style.css" \
	  --resource=../web \
	  --asciidoc-opts="--conf-file version.config" \
	  $<

doc: $(DOCS_HTML)

doc-upload: doc
	rsync -avLP $(DOCS_HTML) $(DOCS_TXT) docbook-xsl.css ../web/style.css "$(WEB)/$(VERSION)/"

clean:
	rm -f $(DOCS_HTML)
