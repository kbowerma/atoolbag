#This is the startup script that runs the serves

echo '\n\n1. Running startup script for '
echo $ATOOLBAG_VERSION
echo "\n\n"

# use for production server (no live reload)
#static-server -p 8000 /opt/adocs/site &


echo '\n \n3. Serving web docs with mkdocs\n'
cd /opt/adocs
mkdocs build
cd /opt/adocs/docs
sed -i "/Welcome/c\# Welcome to Atrium Toolbag $ATOOLBAG_VERSION" index.md


cd /opt/server;

#mkdocs serve -a 0.0.0.0:8000  &
npm install

# Start the server 

echo '\n\n4. starting express server'

cd /opt/server
nodemon index.js &


echo '\n \n5. Running Jupyter\n'


jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=$JUPYTER_PORT --config='/opt/config/jupyter_notebook_config.py' --no-browser --allow-root 