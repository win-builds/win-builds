all:
	@echo "Nothing to build besides the doc."
	true

DOCS:=doc
DOCS_TXT:=$(DOCS:%=%.txt)
DOCS_HTML:=$(DOCS:%=%.html)

%.html: %.txt
	a2x -f xhtml $<

doc: $(DOCS_HTML) package-list.txt

doc-upload: doc
	rsync $(DOCS_HTML) $(DOCS_TXT) docbook-xsl.css notk.org:public_html/yypkg/
