include ../Makefile.data

FILES = index support documentation download news

all web: temp $(patsubst %,temp/%.html,$(FILES))
	cp -a screenshot.png temp

temp:
	mkdir -p temp

temp/index.html: package-list.js
temp/%.html: temp footer.html header.html head.php %.php style.css ../Makefile.data
	php "$*.php" \
	  | sed 's/@@VERSION@@/$(VERSION)/g' \
	  > "$@"

web-upload upload: web
	rsync -avzLP "temp/" "$(WEB)/"

.PHONY: upload
