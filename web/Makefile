include ../Makefile.data

version-agnostic-upload-files = index support
version-specific-upload-files = documentation download news

temp:
	rm -r temp
	mkdir -p temp

temp/%.html: temp footer.html header.html head.php %.php
	php "$*.php" | sed 's/@@VERSION@@/$(VERSION)/g' > "$@"

.SECONDEXPANSION:

version-agnostic-upload version-specific-upload: $$(patsubst %,temp/%.html,$$($$(@)-files))
	cp *.css "temp"
	rsync -avzLP "temp/" "$(WEB)/"

.PHONY: version-agnostic-upload version-specific-upload temp
