#!/bin/bash

#Para mostrar los comandos que se van ejecutando.
set -ex

#Actualización de los repositorios.
apt update

#Actualizar paquetes.
apt upgrade -y

#apache
apt install apache2 -y

# Habilitamos el módulo rewrite
a2enmod rewrite

#Asegúrate de que la ruta sea correcta; "sites-available" debe ser el nombre correcto.
cp ../conf/000-default.conf /etc/apache2/sites-available/

#Instalamos PHP y algunos modulos de PhP para apache y mysql
apt install php libapache2-mod-php php-mysql -y

#Reiniciamos el servicio de Apache
systemctl restart apache2

#mysql
apt install mysql-server -y

#copiamos el scritp de prueba php
cp /home/ubuntu/practica-iaw-1.1/php/index.php /var/www/html

#modificamos el propietario y el grupo del archivo index.php
chown -R www-data:www-data /var/www/html

