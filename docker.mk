SHELL = /bin/bash

PYTHON_DIR = .venv
MAKO_CMD = ${PYTHON_DIR}/bin/mako-render
PIP_CMD = ${PYTHON_DIR}/bin/pip

# Author: Martin Kunzi\
Using this library: \
Step 1: include the library inside your own make file.\
Step 2: Call the desired functions \
Steo 3; Profit\

#Will simply build the image, no fancy stuff.
define dockerbuild
	docker build -t swisstopo/${2}:${3} ${1}
endef

define create_user
	$(call clean)
	if test "$$(ls -la | grep "venv")" == ""; then \
		virtualenv ${PYTHON_DIR}; \
		${PIP_CMD} install -r requirements.txt;\
	fi
endef

define run
	$(call docker-compose.yml,${1},$$(cat ${1}/${2}.arg))
	docker-compose -f ${1}/docker-compose.yml up -d
endef

define clean
	sudo rm -rf .venv
endef

define clean-%
	echo "for on all files that end in .in, then rm those files without the .in"
endef

define purge-%
	for line in $$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "swisstopo" | grep "${1}"); do \
		if test "$$(sudo docker ps --filter "ancestor=$$line" -a -q)" != ""; then  \
			sudo echo "$$(sudo docker ps --filter "ancestor=$$line" -a --format "Removing : {{.Names}}")" ; \
			sudo docker rm -f "$$(sudo docker ps --filter "ancestor=$$line" -a -q)"; \
		fi; \
	sudo docker rmi -f $$line ; \
	done
endef


define push
	for image in $$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "swisstopo" | grep ${1} | grep :${2}); do \
	echo $$image; \
	sudo docker push $$image ; \
	done
endef

define docker-compose.yml
	echo ${2}; \
	sudo ${MAKO_CMD} ${2} ${1}/docker-compose.yml.in  > ${1}/docker-compose.yml
endef

