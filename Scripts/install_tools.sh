#!/bin/bash

#Importamos el archivo de variables

source .env

# Configuramos para mostrar los comandos 
set -ex

# Actualizamos repositorios
apt update

# Actualiza paquetes
apt upgrade -y

#configuramos respuestas para instalacion phpMyadmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

#instalamos phpMyadmin
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

#--------------------------------------------

#instalamos Adminer

#paso 1 creamos directorio adminer
mkdir -p /var/www/html/adminer

#paso 2 descargamos el archivo adminer 
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

#paso 3 renombramos el nombre del script
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

# paso 4 modificamos el propietario y el grupo del archivo
chown -R www-data:www-data /var/www/html/adminer

#------------------------------
#creamos base de datos de ejemplo
#mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
#mysql -u root <<< "CREATE DATABASE $DB_NAME"

#Creamos usuario para la base de datos de ejemplo
#mysql -u root <<< "DROP USER IF EXISTS '$DB_USER'@'%'"
#mysql -u root <<< "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
#mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'"

#-----------------------------------------------------------------
#instalacion de GoAcces
apt install goaccess -y

#Creamos un directorio para los informes estadisticos
mkdir -p /var/www/html/stats

#Ejecutamos GoAcces en background
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize

#Usamos index.html para que cargue automáticamente.

#Control de acceso a un directorio con autenticación básica
#Llevarme el archivo al archivo
