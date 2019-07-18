SHELL = /bin/bash

define subst_credentials_to_env
    if test "$$(ls ${1} | grep rc_credentials_${2})" != ""; then \
	    source ${1}/rc_credentials_${2} && envsubst < ${1}/env.in > ${1}/${2}.env ;\
    fi;
endef
