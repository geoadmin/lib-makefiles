SHELL = /bin/bash

PYTHON_DIR = .venv
MAKO_CMD = ${PYTHON_DIR}/bin/mako-render

# Author: Martin Kunzi\
Using this library: \
Step 1: include the library inside your own make file.\
Step 2: Call the desired functions \
Steo 3; Profit\


define run
	$(call docker-compose.yml,${1},$$(cat ${1}/${2}.arg))
	docker-compose -f ${1}/docker-compose.yml up -d
endef

define composer-clean
	rm ${1}/*.in
endef

define docker-compose.yml
	sudo ${MAKO_CMD} ${2} ${1}/docker-compose.yml.in  > ${1}/docker-compose.yml
endef

