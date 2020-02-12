#This is the startup script that runs the serves

echo '\n\n1. Running starup script\n'

# use for production server (no live reload)
#static-server -p 8000 /opt/notebooks/www/site &
# use for live reload (editing the mkdocs site)
echo '\n\n2. updating web docs\n'

cd /opt/notebooks/www; ls; git pull
sed -i s/Atrium\ Toolbag/Atrium\ Toolbag\ $ATOOLBAG_VERSION/g /opt/notebooks/www/docs/index.md


echo '\n \n3. Serving web docs with mkdocs\n'
cd /opt/notebooks/www;
mkdocs serve -a 0.0.0.0:8000  &
#/usr/local/bin/pgadmin-entrypoint.sh &
#pgadmin4 &

echo '\n \n4. Running Jupyter\n'

jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=$PORT --config='/opt/config/jupyter_notebook_config.py' --no-browser --allow-root 