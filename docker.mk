SHELL = /bin/bash
# Author: Martin Kunzi\
Using this library: \
Step 0: include the integrity library inside your own make file.\
Step 1: include the library inside your own make file.\
Step 2: Call the desired functions \
Steo 3; Profit\

#Will simply build the image, no fancy stuff.
define dockerbuild
	$(call guard,ORGNAME)
	docker build -t ${ORGNAME}/${2}:${3} ${1}
endef

define purge
	$(call guard,ORGNAME)
	for line in $$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "${ORGNAME}" | grep "${1}"); do \
		if test "$$(docker ps --filter "ancestor=$$line" -a -q)" != ""; then  \
			echo "$$(docker ps --filter "ancestor=$$line" -a --format "Removing : {{.Names}}")" ; \
			docker rm -f "$$(docker ps --filter "ancestor=$$line" -a -q)"; \
		fi; \
	docker rmi -f $$line ; \
	done
endef

define push
	$(call guard,ORGNAME)
	for image in $$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "${ORGNAME}" | grep ${1} | grep :${2}); do \
	echo $$image; \
	docker push $$image ; \
	done
endef


