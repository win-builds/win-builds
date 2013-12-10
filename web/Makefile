DEST="notk.org:/var/www/win-builds.org"

upload:
	mkdir -p 'temp'
	for f in $$(git ls-files '*.php'); do php "$${f}" > "temp/$${f%%.php}.html"; done
	cp *.css temp
	rsync -avzLP 'temp/' "$(DEST)/"
	rm -r 'temp'
