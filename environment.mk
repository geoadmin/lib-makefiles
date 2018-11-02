SHELL = /bin/bash

PYTHON_DIR = .venv
PIP_CMD = ${PYTHON_DIR}/bin/pip

# Author: Martin Kunzi\
Using this library: \
Step 1: include the library inside your own make file.\
Step 2: Call the desired functions \
Steo 3; Profit\


define create_env
	$(call clean)
	if test "$$(ls -la | grep "venv")" == ""; then \
		virtualenv ${PYTHON_DIR}; \
		${PIP_CMD} install -r requirements.txt;\
	fi
endef


define clean_env
	sudo rm -rf .venv
endef
