include ../Makefile.data

FILES = index support documentation download news comparison packages_overview

temp/screenshot.png: temp screenshot-windows.png
	pngnq -L < screenshot-windows.png > temp/screenshot.png

all web: temp $(patsubst %,temp/%.html,$(FILES)) temp/screenshot.png

temp:
	mkdir -p temp

temp/packages_overview.html temp/index.html: temp/packages_overview_data.php
temp/%.html: temp footer.html header.html head.php %.php style.css ../Makefile.data
	php "$*.php" \
	  | sed 's/@@VERSION@@/$(VERSION)/g' \
	  > "$@"

web-upload upload: web
	rsync -avzLP "temp/" "$(WEB)/"

temp/packages_overview_data.php:
	(echo '<?php $$packages = ['; \
	LOGLEVEL=dbg make -C .. WINDOWS= 2>&1 \
	  | sed -n 's/^Adding package "\(.*\)" "\(.*\)" \(.*\)\.$$/\1 \2 \3/ p' \
	  | sort \
	  | uniq \
	  | while read l; do \
	      set $${l}; \
	      if [ $${1} = "yypkg" ] || [ $${3} -eq -1 ]; then continue; fi; \
	      echo "  [ \"$$1\", \"$$2\", $$3 ],"; \
	    done; \
	echo ']; ?>'; \
	) > "temp/packages_overview_data.php"

.PHONY: upload temp/packages_overview_data.php
