SHELL = /bin/bash

define rancherdeploy
	$(call docker-compose.yml,${1},$$(cat ${1}/$(shell echo ${2} | tr A-Z a-z).arg))
	$(call rancher-compose,${1},$$(cat ${1}/r$(shell echo ${2} | tr A-Z a-z).arg))
	$(call guard,RANCHER_ACCESS_KEY_${2})
	$(call guard,RANCHER_SECRET_KEY_${2})
	$(call guard,RANCHER_URL_${2})
	rancher -f ${1}/docker-compose.yml -rancher-file ${1}/rancher-compose.yml --access-key ${RANCHER_ACCESS_KEY_${2}} --secret-key ${RANCHER_SECRET_KEY_${2}} --url ${RANCHER_URL_${2}} rm --stop --type stack ${3}-${1}-$(shell echo ${2} | tr A-Z a-z) || echo "Nothing to remove"
	rancher -f ${1}/docker-compose.yml -rancher-file ${1}/rancher-compose.yml --access-key ${RANCHER_ACCESS_KEY_${2}} --secret-key ${RANCHER_SECRET_KEY_${2}} --url ${RANCHER_URL_${2}} up --stack ${3}-${1}-$(shell echo ${2} | tr A-Z a-z) --pull --force-upgrade --confirm-upgrade -d
endef

define rancher-compose
	sudo ${MAKO_CMD} ${2} ${1}/rancher-compose.yml.in > ${1}/rancher-compose.yml
endef
