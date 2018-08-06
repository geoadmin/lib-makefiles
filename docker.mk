SHELL = /bin/bash

# Author: Martin Kunzi\
Using this library: \
Step 1: include the library inside your own make file.\
Step 2: Call the desired functions \
Steo 3; Profit\

define dockerhelp

	@echo "The goal of this library is to provide functions to harmonize and ease the use of docker in the different swisstopo projects. This help should tell you how to use the different functions."
	@echo "dockerbuild : called with call dockerbuild,[mako_cmd],[image_base_name], [dev|int|prod], [additional variables]"
	@echo "[dev|int|prod] is the staging environment. it defines both the tag of the built image and the 'staging' variable for mako to replace in your docker-compose.yml.in."
	@echo "[mako_cmd] refers to the mako command. it is, usually, in your python virtual environment in $${python_directory}/bin/mako-render"
	@echo "[image_base_name] will give a image_base_name variable for the mako render which will be swisstopo/[image_base_name]."
	@echo "[additional variables] should be a string in the following form: --var 'var_name=value' --var 'var_name_2=value_2' etc. The goal is to provide all variables that are specific to your project. "
	@echo "Example of use : call dockerbuild, dev, .venv/bin/mako-render, service-example,--var 'ci=true') could build the swisstopo/service-example:dev and swisstopo/service-example-nginx:dev images"
	@echo "dockerrun: called with call dockerrun, [mako_cmd], [image_base_name],[dev | int | prod],  [additional variables]"
	@echo "Same function as dockerbuild, but it will run the images in containers."
	@echo "dockerpurge : called with call dockerpurge, [image_name]"
	@echo "it will remove all containers running and images whose image name"
	@echo "are swisstopo/[image_name] with any tag."
	@echo "dockerpush: called with call dockerpush, [image_name], [tag]"
	@echo "will push to the swisstopo dockerhub the swisstopo/[image_name]:[tag] image."
	@echo "dockerdeploy: called with call call dockerdeploy,[mako_cmd], [image_base_name], [dev | int | prod], [additional variables]"
endef

define dockerbuild
	$(call docker-compose.yml,${1},false,${2},${3},${4}) && sudo docker-compose build
endef

define dockerrun
	$(call docker-compose.yml,${1},false,${2},${3},${4}) && sudo docker-compose up -d
endef

define docker-clean
	sudo rm -f docker-compose.yml
endef


define dockerpurge
	for line in $$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "swisstopo" | grep "${1}"); do \
		if test "$$(sudo docker ps --filter "ancestor=$$line" -a -q)" != ""; then  \
			sudo docker rm -f "$$(sudo docker ps --filter "ancestor=$$line" -a -q)"; \
		fi; \
	sudo docker rmi -f $$line ; \
	done
endef


define dockerpush
	for image in $$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "swisstopo" | grep ${1} | grep :${2}); do \
	echo $$image; \
	sudo docker push $$image ; \
	done
endef

#Okay, this is ugly, but it works

define dockerpipe
	$(call dockerpurge,${2}) 
	$(call dockerbuild,${1},${2},${3},${4})
	for line in $$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "swisstopo" | grep ${2} | grep ${3}) ; do \
	sudo docker tag $$line "$$line"_$$(date +%Y_%m_%d) ; \
	$(call dockerpush,"$$line_"$$(date +%Y_%m_%d),) ; \
	done ;
endef

# $1 is the MAKO COMMAND and $4 is the base name of the image built \
# $3 is the environment (dev, int, prod) and $2 is the variable that tells the docker compose if he \
# is preparing to deploy to rancher.
# $5 is composed of all variables used in the docker compose in the format 
# --var "var_1=val_1" --var "var_2=val_2" --var "var_3=val_3"

define docker-compose.yml
        sudo ${1} docker-compose.yml.in --var "rancher_deploy=${2}" --var "image_base_name=${3}" --var "environment=${4}" ${5} > docker-compose.yml
endef

