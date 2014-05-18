include ../Makefile.data

web-upload:
	mkdir -p 'temp'
	for f in $$(git ls-files '*.php'); do \
	  php "$${f}" \
	  | sed 's/@@VERSION@@/$(VERSION)/g' \
	  > "temp/$${f%%.php}.html"; \
	done
	cp *.css temp
	rsync -avzLP 'temp/' "$(WEB)/"
