Philosophy and Goals of the repository : 

Makefiles in the different projects are maintained in a happy go lucky fashion. There is no standardisation and more often than not, those makefiles were initially copied from another repository and somehow adapted. With a few Makefile function libraries, the goal is to standardise the makefiles and make them call pre defined functions with parameters.



How to Use ?



First Step : add this repository as a submodule in your project.

Then include the following libraries into your makefile

Include ./lib-makefile/docker.lib if you need docker support
Include ./lib-makefile/rancher.lib if you need rancher support.

Second Step: Call the methods of the libraries

A method is meant to be called with $(function [param1],[param2],[etc.])

  Methods in docker.lib:
    dockerbuild {environment},{image_tag} :
      parameters : 
        environment: {dev|int|prod}
        image_tag {version_name | staging | latest}
      
    dockerrun :{environment},{image_tag} :
      parameters :
        environment: {dev|int|prod}
        image_tag {version_name | staging | latest}

    dockerpurge {image_tag} :
        image_tag {version_name | staging | latest}

    dockerpush {image_tag} :
        image_tag {version_name | staging | latest}

  methods in rancher.lib:
    rancherdeploy {image_tag}
Conventions and Obligations to this repository:

As these libraries are used by multiple projects, if they break, they'll break the ability to deploy a lot of projects.
Which means that you should not modify the interface of an existing function ( The inputs and outputs of the function). 


