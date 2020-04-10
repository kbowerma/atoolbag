#  This file will build version  5.1 of the atoolbag
# it assumes that you have generated ssh keys and have uploaded your public key
# to the bitbucket repo
# version 5.3 is the same as 5.2 (express middelware working local) but will attempt to remove the server logic
#    from adocs and put it in atoolbag.
# version 5.4
#   use .env for all ports



echo "\n\n Building the atoolbag:5.4 image"

echo '\n checking for existance of express.env'

if [ -f "express.env" ]; then echo 'express.env file exists\n'; cat express.env; echo '\n\n'; sleep 2; fi
if [ ! -f "express.env" ]; then echo 'express.envdoes not exist touching now ';  cp express-sample.env express.env ; fi



# Un comment the line below to uplaod your ssh keys to the container
docker build  -t atoolbag:5.4  --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"  . 

# Un Comment the line below and comment the line above if you dont want to push your ssh keys to the repo and you wont be able to automaticly push and pull
# docker build  -t atoolbag:5.1  . 



echo "\n\n REMINDER: the container will do a git pull every time it starts so be sure you are aware of this, comment out the docker-entrypoint.sh file if you want to supress this feature"

echo "\n\n If you want PG and other serivice to run in addtion to the Atrium Tool bag run: docker-compose up \n\n"

echo "\n\n now run:\n\n docker-compose up \n\n or \n docker run -it -p:8000:8000 --name mytoolbag5.4 atoolbag:5.4 \n"