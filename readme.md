# a_toolbag

This project is a collection of data management and AI tools installed on Docker.  Python and R running on Jupyter Notebooks inside the container provide the primary work tool set.  ExpressJS is also running as a webserver and hosts a 'static site' that can be customized for each project. The site is generated by Mkdocs. Express also has a middleware ```http-proxy-middleware``` to map both Jupyter and the static site to a single port.  Passport and passport-auth0 are installed so the static site can be secured. 

to goto the static site:   ```http://localhost:8000```
to goto Jupyter Notebook ```http://localhost:8000/notebook``` (password protected)




## Quick start: Building the image amd starting the container

1. Clone the Repo: ```git clone --recursive https://github.com/kbowerma/atoolbag.git```  be sure you add the ```--recursive``` switch because adocs is a git submodule.
1. The adocs submodules is used for the static site.  So you forget to pull that from the clone you can run ```git submodule update --init --recursive```.   You should check that the
adoc directory has files in it once you are done.
1. Create the .env file from the [Sample ENV file](#sample-env-file) section at the end of this readme. Paste the content of this section into a new file called ```.env```
1. Build the image: ``` docker-compose build```
1. _Optional_ Update the docker-compose.yml and rename the ```container_name```  to your project name, (the default is mytoolbag6)  you may also change the image name that the ```docker-compose build``` will generate.
1. Start the container ```docker-compose up```
2. Alternately you can run the container:  ```docker run -it -p:8888:8888 --env-file .env --name mytoolbag  atoolbag ```
3. Open:  ```localhost:8000``` on your browser and you should see the sample static site.
4. Open ```localhost:8000/notebook``` to launch Jupyter and use the password that starts with an 'a'.
4. If you don't have the password you can create your own by putting the hashed password in the included config file.   See [prepare hashed password](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password) in the docs for details on how to do this.
4. shell into the container: ```docker exec -it mytoolbag6 /bin/bash``` or you can log into a terminal from Jupyter


## Features

* [Jupyter Notebook](https://jupyter.org/)
* [Anaconda (Python)](https://docs.conda.io/projects/conda/en/latest/index.html)
* Multiple Versions of python (2.7.1, 3.6.1, 3.8.1) selected via Jupyter
  * [mkdocs](https://www.mkdocs.org/) - a static site genrator from a git repo
* [Heroku Cli](https://devcenter.heroku.com/articles/heroku-cli)
* [SFDX](https://developer.salesforce.com/tools/sfdxcli)
* [Jq](https://stedolan.github.io/jq/) - a json query and format tool
* [R](https://www.r-project.org/) with bindings to Jupyter
* [NodeJS](https://nodejs.org/en/)
  * npm
  * [static-server](https://github.com/nbluis/static-server#readme)
  * [express](https://expressjs.com/)
  * [Express http-proxy-middleware](https://github.com/chimurai/http-proxy-middleware)
  * [passport](http://www.passportjs.org/)
  * [passport-auth0](https://github.com/auth0/passport-auth0)
* [PostreSql](https://www.postgresql.org/)
* Terminal via Jupyter or via docker exec
* [Data Version Control](https://dvc.org/)

## Repos ( in /opt/repos)
 * [clusterForce](https://github.com/kbowerma/clusterForce)  
 * [sfdc-ci-toolkit](https://github.com/scolladon/sfdc-ci-toolkit)
 * [Static Site Content: adocs](https://github.com/kbowerma/adocs) 


# Docker Container services

This image is Monolithic and contains at least two services.  The are run from inside the container via the docker-entrypoint.sh.   This script also gets the latest repos if needed.  This file can be edited to run new startup tasks.

## Env file

The env file ```.env``` is used both at build time and run time and is required.  Create this file by copying the [Sample ENV file](#sample-env-file) section to a file in root dir.

## Volumes

Prior to version 6, the images used git to pull project documentation into the container.  The required the user to also push to get from inside the container.   Now with version 6, volumes are used so users can git PULL and PUSH from their localhost not from inside the running container.

## Content

The project atoolbag, uses a git submodule called adocs that sets up the mkdocs static site.   The users must pull this submodule before they start the container.



#### Connect to shell 

```docker exec -it mytoolbag6 bash``` will give you root access to the running container. 
or if you just need a new container just for shell tools you can run ```docker run -it atoolbag:6.0  bash```

### Auth for static site

To enable OAuth2 on the static site create a env var called ```USEAUTH``` and set the value to true.  By simply setting the values in the .env file and creating a Auth0 free account on Heroku you can auth the static server.

### Switching Python and R version
For python in Jupyter you can just sinple select the kernel/Python version when you create a new notebook. To switch the command line version of Python you nned to switch Conda's virtual environment.

* ```conda env list``` shows environments 
* ```conda activate py36``` switches to Python 3.6.  Note you may need to install packages into these new environments with conda or pip.

For switching versions of node the ```n``` node manager has been installed.   You can simply type ```n``` to enable the version selector.  Only 11.12.0 and 12.16.1 are installed by default.   To install and switch to a new version simply run:  ```n ls-remote``` to see the available version and then:  ```n 14.1.0``` to install that version.


## Deploy to Heroku

### [Deploy to Heroku (Container registry and runtime method - Docker dployes)](https://devcenter.heroku.com/articles/container-registry-and-runtime)


1. Crete a Heroku app ``` heroku create```
2. Log into container registry  ```heroku container:login```
3. Assuming you have a Dockerfile in your root dir ```heroku container:push web```
4. and Deploy, release the container ```heroku container:release web
5. tail the logs so you can learn the token ```heroku logs --tail --app obscure-ravine-22779``

## Running multiple service without the docker-entrypoint.sh shell (Advanced)
Jupyter notebook runs on port 8888 and is mapped to the same port on the local host.  [Mkdocs](https://www.mkdocs.org/) - a static site generator templated from markdown, is also installed and can be configured to run on any port including 8080.  Here is the command to expose both Juypter notebook (and start it) and a extra port for mkdocs:  

```docker run -it -p:8888:8888 -p:8080:8080 --name mytoolbag  atoolbag:1.6 /bin/bash -c "/opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser --allow-root --config='/opt/config/jupyter_notebook_config.py'"```  

-note that mkdocs is not running by opening a terminal in Jupyter you can navigate to a directory and generate a mkdocs site with ```mkdocs new mysite``` then serve the new site on 8080 with ```mkdocs serve --dev-addr=0.0.0.0:8080 --livereload``` 

## Pushing to Docker Hub

```
docker tag 252ced01b5f5 kbowerma/atoolbag:3.4
docker tag 252ced01b5f5 kbowerma/atoolbag:latest
docker login
docker push kbowerma/atoolbag
```

## Releases

### Version 3.5  1/25/2020

  * Supports R and multiple versions of python via in Juypter notebooks

### Version 3.6

* [x] static landing page generated from mkdocs, ``` open localhost:80```
* [x] Edit static site with live reload
* [x] startup.sh script added to launch multiple services on one container
* [x] pulls in Repo for landing page from https://github.com/kbowerma/adocs.git
* [x] pg Admin support added 
* startup: ```docker run -it -p 8888:8888 -p 80:8000 --rm --name mytoolbag36 kbowerma/atoolbag:3.6```

### Version 3.7

* [x] removed dvc, it caused conflicts with conda
* [x] added compose file includes containers for: postgres, adminer, pgweb
* [x] removed postgres from toolbag over seperate container.
* [x] renamed startype.sh to docker-entrypoint.sh
* [x] update content from github kbowerma/adocs

 ## Version 4.0

* [x] rebased repo
* [x] services running on consecutive ports
* [x] hasura support port 84

## Version 5.2

 * Express middleware to support OAuth


## Version 5.4

 * use env for all ports
 * removes server logic

## Version 5.5

 * leverage docker compose but needs build.sh script for ssh args
 * uses middleware proxy _http-proxy-middleware_ which mapps jupyter (8888)  though a route ```localhost:8000/notebook```

 ## Version 5.6 

 * env.USEAUTH=true is required to use OAUTH

  ## Version 5.7 

 * Uses [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) to allow for faster and more robust rebuilds.

## Version 6.0
 Removal of sub repos for projects, notebooks and data by using volumes instead.

## Sample ENV file
```
THIS_HOST=localhost
ATOOLBAG_VERSION=5.6
AUTH0_CLIENT_ID=some_value
AUTH0_DOMAIN=some_value
AUTH0_CLIENT_SECRET=some_value
AUTH0_CALLBACK_URL=http://localhost:8000/callback
JUPYTER_PORT=8888
STATIC_PORT=8000
PORT=8000
USEAUTH=false
```

## TODO









