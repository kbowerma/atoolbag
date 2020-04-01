#  This file will build version  5.1 of the atoolbag
# it assumes that you have generated ssh keys and have uploaded your public key
# to the bitbucket repo

echo "\n\n Building the atoolbag:5.1 image"

# Un comment the line below to uplaod your ssh keys to the container
docker build  -t atoolbag:5.1  --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"  . 

# Un Comment the line below and comment the line above if you dont want to push your ssh keys to the repo and you wont be able to automaticly push and pull
# docker build  -t atoolbag:5.1  . 



echo "\n\n REMINDER: the container will do a git pull every time it starts so be sure you are aware of this, comment out the docker-entrypoint.sh file if you want to supress this feature"

echo "\n\n If you want PG and other serivice to run in addtion to the Atrium Tool bag run: docker-compose up \n\n"

echo "\n\n now run:\n\n docker run -it -p:8000:8000 -p:8888:8888 --name mytoolbag5.1 atoolbag:5.1 \n"