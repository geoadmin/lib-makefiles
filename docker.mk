SHELL = /bin/bash

# Docker Build \
The goal of this function is to build your images. As such, you will need to specify  \
$1: the MAKO_CMD path (usually: ${PYTHON_DIR}/bin/mako-render), PYTHON DIR being usually .venv \
$2 : is it a rancher deploy (true | false)\
$3: the CI parameter : is the instruction part of a continuous integration (true | false) \
$4: the environment used (int, dev, prod)\
$5: the image tag used\
$6: the complete list of all other variables used by the docker compose, in the following format :\
--var "param_name_in_docker-compose.yml.in=value of that parameter" --var ... \  

define dockerbuild
	$(call docker-compose.yml, $1, $2, $3, $4, $5, $6 ) && docker-compose build
endef

define dockerrun
	$(call docker-compose.yml, $1, $2, $3, $4) && docker-compose up -d
endef

define dockerpurge
	@if test "service is running"
		echo "MEH"
	fi
        @if test "
endef

define dockerpush
	echo "LET'S PUSH ${2} TO DOCKERHUB"
endef

define docker-compose.yml
	source rc_user && ${1} --var "rancher_deploy"=${2}" --var "ci=${3}" --var "staging=${4}" --var "image_tag=${5}" ${6} docker-compose.yml.in > docker-compose.yml 
endef
