include ../Makefile.data

FILES = index support documentation download news comparison packages

temp/screenshot.png: temp screenshot-windows.png
	pngnq -L < screenshot-windows.png > temp/screenshot.png
	advpng -h >/dev/null && advpng -z -4 temp/screenshot.png

all web: temp $(patsubst %,temp/%.html,$(FILES)) temp/screenshot.png

temp:
	mkdir -p temp

temp/%.html: temp footer.html header.html head.php %.php style.css ../Makefile.data
	sed 's/@@VERSION@@/$(VERSION)/g' "$*.php" \
	  | php \
	  > "$@"

temp/packages.html temp/index.html temp/download.html: packages_common.php

web-upload upload: web
	rsync -avzLP "temp/" "$(WEB)/"

.PHONY: upload
