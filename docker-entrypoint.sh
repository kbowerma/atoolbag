#This is the startup script that runs the serves

echo "\n\n1. Running startup script for $ATOOLBAG_VERSION "
echo $ATOOLBAG_VERSION
echo "\n\n"

LIVESERVER=TRUE

# use for production server (no live reload)
#static-server -p 8000 /opt/adocs/site &


echo '\n \n2. Building web docs with mkdocs\n'
#cd /opt/adocs/docs
sed -i "/Welcome/c\# Welcome to Atrium Toolbag $ATOOLBAG_VERSION" /opt/adocs/docs/index.md

# build the static site even though it might be run from mkdocs serve 
cd /opt/adocs
mkdocs build

# Start the server 

# choose this option to serve from the mkdocs live server so you can edit the markdown

if [ "$LIVESERVER" = "TRUE" ]; then
# OPTION A: start the mkdoc live server
    echo '\n3. \t ... stating mkdocs live server'
    sed -i "/Welcome/c\# Welcome to Atrium Toolbag $ATOOLBAG_VERSION Live server" /opt/adocs/docs/index.md

    mkdocs serve -a 0.0.0.0:$STATIC_PORT  & 
else
    #  or OPTION B start static server (you have to  build it becuase it is a volume not a copy)
    cd /opt/server;
    npm install
    echo '\n\n3. starting express static server'
    sed -i  "s/Version.*$/Version $ATOOLBAG_VERSION static server<\/a><\/li>/"  /opt/adocs/site/index.html
fi

echo '\n \n4. Running Jupyter\n'


jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=$JUPYTER_PORT --config='/opt/config/jupyter_notebook_config.py' --no-browser --allow-root 