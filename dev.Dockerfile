FROM continuumio/anaconda3 AS myconda
 ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
 ENV PATH /opt/conda/bin:$PATH
 ENV PROJ_LIB /opt/conda/share/proj
 #Upgrade to know version of conda
 RUN conda --version
 RUN conda install conda=4.8.3
 RUN conda --version
 RUN /opt/conda/bin/conda install jupyter -y --quiet
 #Install Python Libaries
 RUN pip install mglearn==0.1.7
 RUN pip install mkdocs==1.0.4
 RUN conda install -y basemap=1.2.0
 RUN conda install -y proj4=5.2.0
 RUN ls -l
 RUN conda --version
 #RUN conda install -y psycopg2=2.8.4 
 RUN pip install psycopg2-binary
 #RUN conda install -y -c conda-forge dvc=0.54.1  #I removed this it Hung the install
 #pip
 RUN pip install  environment_kernels
 RUN conda create -n py27 python=2.7 ipykernel
 RUN conda create -n py36 python=3.6 ipykernel
 RUN conda create -n py38 python=3.8 ipykernel
 # react componenet fix
 WORKDIR /opt/conda/lib/python3.7/site-packages/notebook/static/components/react
 RUN wget  https://unpkg.com/react-dom@16/umd/react-dom.production.min.js
 # Save for end since it is data
 RUN mkdir /opt/config
 ADD jupyter_notebook_config.py /opt/config
 # COPY jupyter_notebook_config.py /opt/config/jupyter_notebook_config.py  #only need one not sure which one works

FROM myconda AS myr
 RUN apt-get update
 RUN apt-get install -y r-base=3.5.2-1
 # Install R
 RUN R -e "install.packages('IRkernel', repos='http://cran.rstudio.com/')"
 RUN R -e "IRkernel::installspec(user = FALSE)"

FROM myr AS mypackages
 RUN mkdir -p /usr/share/man/man1
 RUN apt-get install -y gnupg=2.2.12-1+deb10u1
 # Node cant find 10.15 anymor
 RUN apt-get install -y curl dirmngr apt-transport-https lsb-release ca-certificates
 RUN apt-get install -y openjdk-11-jre-headless=11.0.6+10-1~deb10u1  openjdk-11-jdk-headless=11.0.6+10-1~deb10u1 
 RUN apt-get install -y postgresql=11+200+deb10u3 postgresql-contrib=11+200+deb10u3
 RUN apt-get install -y jq=1.5+dfsg-2+b1   vim=2:8.1.0875-5
 # Install Heroku CLI
 RUN curl  https://cli-assets.heroku.com/install-ubuntu.sh | sh
 #Install SFDX
 RUN wget https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz
 RUN mkdir sfdx
 RUN tar xJf sfdx-linux-amd64.tar.xz -C sfdx --strip-components 1
 RUN ./sfdx/install

FROM mypackages AS mynode
 RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash
 RUN apt-get  install -y nodejs
 #upgrade node 
 RUN npm cache clean -f
 RUN npm install -g n
 RUN n 11.12.0
 RUN n 12.16.1
 RUN node -v
 RUN npm install -g nodemon
 #install node static server
 RUN npm install -g static-server@2.2.1

FROM mynode AS mydata
 RUN mkdir /opt/notebooks
 RUN mkdir /opt/data
 RUN mkdir /opt/notebooks/data
 RUN mkdir /opt/repos
 WORKDIR /opt/repos
 # Get some Repos
 RUN git clone https://github.com/scolladon/sfdc-ci-toolkit.git
 RUN git clone https://github.com/kbowerma/clusterForce.git
 # adocs is the static site template
 RUN git clone https://github.com/kbowerma/adocs.git /opt/notebooks/www
 RUN cp /opt/repos/clusterForce/notebooks/cityAssinger.ipynb  /opt/notebooks/
 RUN cp /opt/repos/clusterForce/notebooks/smartCityAssignmentsV2-plusCluster.ipynb /opt/notebooks/
 RUN cp /opt/repos/clusterForce/notebooks/Data/* /opt/notebooks/data
 #now install the Express/passport kit from the package.json in adocs 
 RUN mkdir /opt/notebooks/server
 COPY server /opt/notebooks/server
 WORKDIR /opt/notebooks/server
 RUN npm install 

 RUN dpkg -l > /opt/notebooks/data/packages.txt
 COPY docker-entrypoint.sh  /opt

 ENTRYPOINT ["sh"]
 CMD ["/opt/docker-entrypoint.sh"]

 # RUN echo -e "\n\nnow run:\n  docker run -it -p:8000:8000 -p:8888:8888 --name mytoolbag"$ATOOLBAG_VERSION" atoolbag:"$ATOOLBAG_VERSION"\n\n"
 RUN echo -e "\n\n run: \e[1m \e[34m docker-compose up \e[0m to start the container \n\n"