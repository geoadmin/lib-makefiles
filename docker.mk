SHELL = /bin/bash

# Author: Martin Kunzi\
Using this library: \
Step 1: include the library inside your own make file.\
Step 2: Call the desired functions \
Steo 3; Profit\

define dockerhelp

	@echo "The goal of this library is to provide functions to harmonize and ease the use of docker in the different swisstopo projects. This help should tell you how to use the different functions."
	@echo "dockerbuild : called with call dockerbuild, [dev|int|prod], [mako_cmd], [image_base_name]"
	@echo "[dev|int|prod] is the staging environment. it defines both the tag of the built image and the 'staging' variable for mako to replace in your docker-compose.yml.in."
	@echo "[mako_cmd] refers to the mako command. it is, usually, in your python virtual environment in $${python_directory}/bin/mako-render"
	@echo "[image_base_name] will give a image_base_name variable for the mako render which will be swisstopo/[image_base_name]."
	@echo "Example of use : call dockerbuild, dev, .venv/bin/mako-render, service-example) could build the swisstopo/service-example:dev and swisstopo/service-example-nginx:dev images"
	@echo "dockerrun: called with call dockerrun, [dev | int | prod], [mako_cmd], [image_base_name]"
	@echo "Same function as dockerbuild, but it will run the images in containers."
	@echo "dockerpurge : called with call dockerpurge, [image_name]"
	@echo "it will remove all containers running and images whose image name"
	@echo "are swisstopo/[image_name] with any tag."
	@echo "dockerpush: called with call dockerpush, [image_name],[tag]"
	@echo "will push to the swisstopo dockerhub the swisstopo/[image_name]:[tag] image."
	@echo "dockerdeploy: called with call call dockerdeploy, [dev | int | prod], [mako_cmd], [image_base_name]"
endef

define dockerbuild
	$(call docker-compose.yml, ${1}, false, ${2}, ${3}) && $(shell docker-compose build)
endef

define dockerrun
	$(call docker-compose.yml, ${1}, false, ${2}, ${3}) && $(shell docker-compose up -d)
endef


define dockerpurge
	for line in $(shell docker images --format "{{.Repository}}:{{.Tag}}" | grep "swisstopo" | grep "${1}"); do \
		@if test "$$(sudo docker ps --filter "ancestor=$$line" -a -q)" != ""; then \
			$$(sudo docker rm -f $$( sudo docker ps --filter "ancestor=$$line" -a -q))
		fi
	$$(sudo docker rmi -f $$line)
	done;
endef

define dockerpush
	@if test "$(shell sudo docker images swisstopo/${1}:${2})" != ""; then \
		docker push swisstopo/${1}:${2} ; \
	else \
		echo "The image swisstopo/${1}:${2} doesn't seem to exist."; \
	fi
endef

define dockerdeploy
	$(call dockerpurge, ${3}) 
	$(call dockerbuild, ${1}, ${2}, ${3})
	images=$(shell docker image --format "{{.Repository}}:{{.Tag}}" | grep "swisstopo" | grep "${3}" | grep "${1}")
	for line in $(images); do \
	$$(docker tag $$line $$line_$(shell date +%Y_%m_%d)) ; \
	$(call dockerpush, ${3}, ${1}_$(shell date +%Y_%m_%d)) ; \
	done ;
endef

# $1 is the environment (dev, int, prod) and $2 is the base name of the image built \
# $3 is the MAKO COMMAND\
# How to use : the env file in (usually) ${1}.env and should be specified in the docker-compose \
# in the form ${staging}.env. If multiples environment files are used, make sure they have the \  
# same nomenclature to call all your needed env files. All the necessary variables to use in your \
# docker-compose should be in your .env file. That way, we have a simple clean unique function. \
# please ? 
define docker-compose.yml
        ${3} docker-compose.yml.in --var "rancher_deploy=${2}" --var "staging=${1}" --var "image_base_name=swisstopo/${4}" > docker-compose.yml
endef

