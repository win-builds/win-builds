include ../Makefile.data

FILES = index support documentation download news comparison packages

temp/screenshot.png: screenshot-windows.png | temp
	pngnq -L < screenshot-windows.png > temp/screenshot.png
	advpng -h >/dev/null && advpng -z -4 temp/screenshot.png

temp/%.png: %.png | temp
	pngnq -L < $*.png > $@
	advpng -h >/dev/null && advpng -z -4 $@

all web: $(patsubst %,temp/%.html,$(FILES)) temp/screenshot.png temp/install_mirror_path.png

temp:
	mkdir -p temp

temp/%.html: footer.html header.html head.php %.php style.css ../Makefile.data | temp
	sed 's/@@VERSION@@/$(VERSION)/g' "$*.php" \
	  | php \
	  > "$@"

temp/packages.html temp/index.html temp/download.html: packages_common.php

web-upload upload: web
	rsync -avzLP "temp/" "$(WEB)/"

.PHONY: upload
