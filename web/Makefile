include ../Makefile.data

FILES = index support documentation download news

all web: temp $(patsubst %,temp/%.html,$(FILES))

temp:
	mkdir -p temp

temp/index.html: package-list.js
temp/%.html: temp footer.html header.html head.php %.php style.css ../Makefile.data
	php "$*.php" \
	  | sed \
	      -e 's/@@VERSION_STABLE@@/$(VERSION_STABLE)/g' \
	      -e 's/@@VERSION_DEV@@/$(VERSION_DEV)/g' \
	  > "$@"

web-upload upload: web
	rsync -avzLP "temp/" "$(WEB)/"

.PHONY: upload
