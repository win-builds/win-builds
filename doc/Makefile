HOST:="notk.org:/var/www/yypkg.org/rc3_32"

DOCS:=doc doc-diy doc-packaging
DOCS_TXT:=$(DOCS:%=%.txt)
DOCS_HTML:=$(DOCS:%=%.html)

%.html: %.txt
	a2x -f xhtml $<

doc: $(DOCS_HTML)

doc-upload: doc
	rsync -avP $(DOCS_HTML) $(DOCS_TXT) docbook-xsl.css $(HOST)/

clean:
	rm -f $(DOCS_HTML)
