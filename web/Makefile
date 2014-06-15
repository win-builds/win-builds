include ../Makefile.data

FILES = index support documentation download news

temp:
	mkdir -p temp

temp/index.html: package-list.js
temp/%.html: temp footer.html header.html head.php %.php style.css ../Makefile.data
	php "$*.php" \
	  | sed \
	      -e 's/@@VERSION_STABLE@@/$(VERSION_STABLE)/g' \
	      -e 's/@@VERSION_DEV@@/$(VERSION_DEV)/g' \
	  > "$@"

upload: $(patsubst %,temp/%.html,$(FILES))
	rsync -avzLP "temp/" "$(WEB)/"

.PHONY: upload
