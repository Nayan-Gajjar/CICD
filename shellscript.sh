#!/bin/bash

# First we will check if postgres has been installed or not
# by this command it will print postgres version if installed or not
# to stdout and stderr
psql -V > /dev/null 2>&1


# Next we will check if above command successfully executed or not
# Here $? will check previsously executed commnad status
# if 0 means successfully executed and if not then fail
if [ $? == 0 ]
then
  echo "Postgress is installed"
else
  echo $password | sudo -S apt install postgresql -y
  echo "Postgress has been installed"
fi


# Next we will check for if database exist or not
# For this first we will create root user and database
# as we will check from sudo commnad otherwise it will
# give error root user and database not exist


# First check if root user and db exists or not
echo $password | sudo -S psql -c '\l' | grep "root" > /dev/null 2>&1
if [ $? == 0 ]
then
  echo "Root db exist"
else
  echo $password | sudo -S -u postgres createdb "root"
  echo "Root db created"
fi

echo $password | sudo -S psql -c '\du' | grep "root" > /dev/null 2>&1
if [ $? == 0 ]
then
  echo "Root user exist"
else
  echo $password | sudo -S -u postgres createuser "root"
  echo "Root user created"
fi


# Next we will check if db exist or not
echo $password | sudo -S psql -c '\l' | grep "demo" > /dev/null 2>&1


# Next we will check if above command successfully executed or not
# Here $? will check previsously executed commnad status
# if 0 means successfully executed and if not then fail
if [ $? == 0 ]
then
  echo "Database exist"
else
  echo $password | sudo -S -u postgres createdb "demo"
  echo "Database created"
fi


# Next we will check if demo user exist or not
echo $password | sudo -S psql -c '\du' | grep "demo" > /dev/null 2>&1
if [ $? == 0 ]
then
  echo "User exist"
else
  echo $password | sudo -S -u postgres createuser "demo";
  echo $password | sudo -S -u postgres psql -c "alter user demo with encrypted password 'demo'";
  echo $password | sudo -S psql -c 'grant all privileges on database "demo" to demo;'
  echo "User created"
fi


# Next we will check if virtualenv package is installed or not
virtualenv --version > /dev/null 2>&1
if [ $? == 0 ]
then
  echo "virtualenv is installed to create venv for python"
else
  echo $password | sudo -S apt install virtualenv -y
  echo "virtualenv has been installed"
fi


# This package will be required to install psycopg2 package of Python
dpkg -l | grep "postgresql-server-dev-all"
if [ $? == 0 ]
then
  echo "postgresql-server-dev-all has been installed"
else
  echo $password | sudo -S apt install postgresql-server-dev-all -y
fi

# Next we will check if venv is there or not
cd Demo
ls | grep "venv" > /dev/null 2>&1
if [ $? == 0 ]
then
  echo "Python vevn available"
  source venv/bin/activate
else
  virtualenv -p python3 venv
  source venv/bin/activate
  pip install -r req.txt
  echo "Python venv has been installed with req.txt"
fi


# Next we will migrate the changes
python manage.py makemigrations
python manage.py migrate


# Next we will start the server
nohup python manage.py runserver > /dev/null 2>&1 &
