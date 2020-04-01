# From https://github.com/ContinuumIO/docker-images/blob/master/anaconda3/debian/Dockerfile
FROM continuumio/anaconda3

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
ENV PROJ_LIB /opt/conda/share/proj
# to run this localy you will need to set the env
ENV PORT 8888

 

# Below is custom Atrium tasks
RUN /opt/conda/bin/conda install jupyter -y --quiet

RUN mkdir /opt/notebooks
RUN mkdir /opt/data
RUN mkdir /opt/repos


#Install Heroku, node, JAVA
RUN more /etc/apt/sources.list
# JAVA stuff https://tecadmin.net/how-to-install-java-on-debian-10-buster/
# postgreSQL: https://tecadmin.net/install-postgresql-server-on-ubuntu/ 
RUN apt-get update
# Hack to get Java install to work
RUN mkdir -p /usr/share/man/man1
RUN apt-get install -y gnupg=2.2.12-1+deb10u1 nodejs=10.15.2~dfsg-2 
#RUN apt-get install -y openjdk-11-jdk=11.0.5+10-1~deb10u1 postgresql=11+200+deb10u3 postgresql-contrib=11+200+deb10u3
RUN apt-get install -y openjdk-11-jdk-headless=11.0.6+10-1~deb10u1 postgresql=11+200+deb10u3 postgresql-contrib=11+200+deb10u3
RUN apt-get install -y jq=1.5+dfsg-2+b1 r-base=3.5.2-1 npm=5.8.0+ds6-4 vim=2:8.1.0875-5


WORKDIR /opt/data
# Install Heroku CLI
RUN curl  https://cli-assets.heroku.com/install-ubuntu.sh | sh

#Install SFDX
RUN wget https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz
RUN mkdir sfdx
RUN tar xJf sfdx-linux-amd64.tar.xz -C sfdx --strip-components 1
RUN ./sfdx/install

#Install Python Libaries
RUN pip install mglearn==0.1.7
RUN pip install mkdocs==1.0.4
RUN conda install -y basemap=1.2.0
RUN conda install -y proj4=5.2.0
RUN conda install -y psycopg2=2.8.4
#RUN conda install -y -c conda-forge dvc=0.54.1  #I removed this it Hung the install

# Install R
RUN R -e "install.packages('IRkernel', repos='http://cran.rstudio.com/')"
RUN R -e "IRkernel::installspec(user = FALSE)"

#install node static server
RUN npm install -g static-server@2.2.1


# Lastly get some data and repos - Always get data last

WORKDIR /opt/repos
RUN git clone https://github.com/scolladon/sfdc-ci-toolkit.git
RUN git clone https://github.com/kbowerma/clusterForce.git
RUN git clone https://github.com/kbowerma/adocs.git /opt/notebooks/www
RUN cp /opt/repos/clusterForce/notebooks/cityAssinger.ipynb  /opt/notebooks/
RUN cp /opt/repos/clusterForce/notebooks/smartCityAssignmentsV2-plusCluster.ipynb /opt/notebooks/

#add the jupter config file
RUN mkdir /opt/config
ADD jupyter_notebook_config.py /opt/config
RUN mkdir /opt/notebooks/data
RUN ls /opt/repos/clusterForce/notebooks
RUN cp /opt/repos/clusterForce/notebooks/Data/* /opt/notebooks/data

#pip

RUN pip install  environment_kernels
RUN conda create -n py27 python=2.7 ipykernel
RUN conda create -n py36 python=3.6 ipykernel
RUN conda create -n py38 python=3.8 ipykernel

# if we need to roll back conda
# RUN conda install -n root conda=4.6
# RUN conda info

# Run some operational stuff
ENV ATOOLBAG_VERSION 5.0
RUN dpkg -l > /opt/notebooks/data/packages.txt


# Leave in webroot
WORKDIR /opt/notebooks/www


COPY docker-entrypoint.sh  /opt

COPY .env /opt/notebooks/www

#upgrade node 
RUN npm cache clean -f
RUN npm install -g n
RUN n 11.12.0
RUN n 12.16.1
RUN node -v
RUN npm install -g nodemon

#now install the Express/passport kit from the package.json in adocs 
RUN ls -l
RUN git pull

RUN npm install 



ENTRYPOINT ["sh"]
CMD ["/opt/docker-entrypoint.sh"]

RUN echo -e "\n\nnow run:\n  docker run -it -p:8000:8000 -p:8888:8888 --name mytoolbag"$ATOOLBAG_VERSION" atoolbag:"$ATOOLBAG_VERSION"\n\n"
#Oauth branch
#RUN echo -e "\n\nnow run:\n\n  docker run -it -p:8000:8000 -p:8888:8888 --name mykoatoolbag atoolbag:koa \n\n"

