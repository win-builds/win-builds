HOST:="notk.org:/var/www/win-builds.org/1.3-alpha2"

DOCS:=index diy packaging
DOCS_TXT:=$(DOCS:%=%.txt)
DOCS_HTML:=$(DOCS:%=%.html)

%.html: %.txt
	a2x -f xhtml $<

doc: $(DOCS_HTML)

doc-upload: doc
	rsync -avP $(DOCS_HTML) $(DOCS_TXT) docbook-xsl.css $(HOST)/

clean:
	rm -f $(DOCS_HTML)
