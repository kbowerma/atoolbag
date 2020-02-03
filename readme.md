# a_toolbag

This project is a collection of data management and AI tools collected on Docker including Python and R running on Jupyter Notebooks inside a docker container

## Quickest start:

1. grab the image from Docker Hub ```docker pull kbowerma/atoolbag:latest```
2. start the container ```docker run -it -p:8888:8888 --name mytoolbag kbowerma/atoolbag:latest```
3. Open a browser ```http://localhosts:8888``` and put in the magic password that Kyle gave you.

## Quickish start: Buliding the image amd starting the container

1. Clone the Repo: ```https://github.com/kbowerma/atoolbag.git```
1. Build the image: ``` docker build -t atoolbag . ```
2. Run the container:  ```docker run -it -p:8888:8888 --name mytoolbag  atoolbag ```
3. Open:  ```localhost:8888``` on your browser and use the password that starts with an 'a'. If you omit the config file copy then you need to use the token. 
click on ouptut link with Token at startup or if you loose the link run this: ```docker exec mytoolbag more /root/.local/share/jupyter/runtime/nbserver-1-open.html```
4. If you don't have the password you can create your own by putting the hashed password in the included config file.   See [prepare hashed password](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password) in the docs for details on how to do this.
4. Shell: ```docker exec -it mytoolbag /bin/bash``` or you can log into a terminal from Jupyter

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
* [PostreSql](https://www.postgresql.org/)
* Terminal via Jupyter or via docker exec
* [Data Version Control](https://dvc.org/)

## Repos ( in /opt/repos)
 * [clusterForce](https://github.com/kbowerma/clusterForce)  
 * [sfdc-ci-toolkit](https://github.com/scolladon/sfdc-ci-toolkit)


## Docker build notes


#### Build

     docker build -t atoolbag:3.4 .

#### Run Jupyter Notebook

**Start Jupyter Notebook**

**The new way** if you have a good startup **CMD** in your docker file that includes the jupyter switches for the notebook dir and ip .. Something like this: *CMD jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=$PORT --config='/opt/config/jupyter_notebook_config.py' --no-browser --allow-root*` and you have the ENV port set to 8888 (```ENV PORT 8888```) then you can run the container with -it (interactive shell, and tty ). You also need to map the local port to remote port (remote must be 8888),  pass it and name (mytoolbag) and specify the image (in this cases it is attobag:3.0)

     docker run -it -p:8888:8888 --name mytoolbag  atoolbag:3.0

**The old way** if your startup **CMD** in the dockerfile just runs bash,  then you need to pass in the jupyter startup parms.  This is useful if you want to customize how Jupyter is started.

     docker run -it -p:8888:8888  --name mytoolbag3  atoolbag:3.0 /bin/bash -c "/opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser --allow-root --config='/opt/config/jupyter_notebook_config.py'"



The above command will return a url with that you can access with you local machine if you have removed the hashed password from the config file and need to use a token.

```
    To access the notebook, open this file in a browser:
        file:///root/.local/share/jupyter/runtime/nbserver-1-open.html
    Or copy and paste one of these URLs:
        http://2108ec7c0003:8888/?token=2e98dcb8705428c5d0371d7dcd1b6764b60b6d507794aa19
     or http://127.0.0.1:8888/?token=2e98dcb8705428c5d0371d7dcd1b6764b60b6d507794aa19
```



**Stop Container running Jupyter and restart it**

```docker stop mytoolbag``` or *containerId* (use ```docker ps``` to show the containerId)
Once you stop the container you wont see it with ```docker ps``` and you will have to use the all switch ```docker ps -a``` once you can see your containter you can start is again with ```docker start mytoolbag```

#### Connect to shell 

```docker exec -it mytoolbag /bin/bash``` will give you root access to the running container. 
or if you just need a new container you can run ```docker run -it atoolbag  /bin/bash```

## Deploy to Heroku

### [Deploy to Heroku (Container registry and runtime method - Docker dployes)](https://devcenter.heroku.com/articles/container-registry-and-runtime)


1. Crete a Heroku app ``` heroku create```
2. Log into container registry  ```heroku container:login```
3. Assuming you have a Dockerfile in your root dir ```heroku container:push web```
4. and Deploy, release the container ```heroku container:release web
5. tail the logs so you can learn the token ```heroku logs --tail --app obscure-ravine-22779``

## Running multiple service
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
  * [*] pulls in Repo for landing page from https://github.com/kbowerma/adocs.git
  * [ ] pg Admin support added 
  * startup: ```docker run -it -p 8888:8888 -p 80:8000 --rm --name mytoolbag36 kbowerma/atoolbag:3.6```

### Version 3.7
 
 [*] removed dvc, it caused conflicts with conda
 [*] added compose file includes containers for: postgres, adminer, pgweb
 [*] removed postgres from toolbag over seperate container.
 [*] renamed startype.sh to docker-entrypoint.sh
 [*] update content from github kbowerma/adocs







