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
	 rm ${1}/docker-compose.yml ${1}/rancher-compose.yml
endef

define docker-compose.yml
	${MAKO_CMD} ${2} ${1}/docker-compose.yml.in  > ${1}/docker-compose.yml
endef

# create env file logic : \
1 - Is there a ${staging}.env.in file ? yes -> go to 2 \
2 - Is there a credentials.${staging}.arg file ? yes -> got to 3, no -> go to 4 \
3 - MAKO credentials.staging.arg staging.env.in > staging.env \
4 - Is there a credentials.arg file ? yes -> go to 5, no -> go to 6 \
5 - MAKO credentials.arg staging.env.in > staging.env \
6 - cp staging.env.in staging.env
define create_env_file
        env_template="${2}.env.in"
        cred_staged_file="credentials.${2}.arg"
        cred_file="credentials.arg"
	if test "$$(ls -la ${1}/ | grep "${env_template}")" != ""; then \
		if test "$$(ls -la ${1} | grep "${cred_staged_file}")" != ""; then \
			${MAKO_CMD} ${cred_staged_file} ${1}/${env_template} > ${1}/${staging}.env \                
		elif test "$$(ls -la ${1} | grep "${cred_file}")" != ""; then \
			${MAKO_CMD} ${cred_file} ${1}/${env_template} > ${1}/${staging}.env \
		else \
			cp "${1}/${env_template}" "${1}/${2}.env" \
		fi \
	fi
endef
