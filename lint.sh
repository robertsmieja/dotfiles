#! /usr/bin/env sh

shellcheck() {
	docker run --rm -v "$PWD:/mnt" koalaman/shellcheck:stable "${1}"
}

getScripts() {
	find . -name "*.sh" -or -name "*.sh.tmpl"
}

SCRIPTS="$(getScripts)"

for script in $SCRIPTS; do
	echo "Linting... ${script}"
	shellcheck "${script}"
done
