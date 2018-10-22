SHELL = /bin/bash

define guard
	if test "${${1}}" = ""; then \
	echo "Environment variable ${1} not set." ; \
	exit 1; \
	fi
endef

define commit_tags
$(shell [ -z "`git status --porcelain`" ] && git rev-parse --short HEAD || echo "unstable")
endef
