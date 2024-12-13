#!/bin/bash

#Importamos el archivo de variables

source .env

# Configuramos para mostrar los comandos 
set -ex

sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"

#Creamos y habilitamos el default-ssl.conf
#Copiamos el archivo del VirtualBox del puerto 443
cp ../conf/default-ssl.conf /etc/apache2/sites-available

#Comprobamos que en site-available está el documento con un cat

#lo habilitamos
sudo a2ensite default-ssl.conf

#Habilitamos el módulo SSL en Apache.
sudo a2enmod ssl

#copiamos el archivo de configuracion del virtualhost del puerto 80.
cp ../conf/000-default.conf /etc/apache2/sites-available

#también despues
sudo a2ensite 000-default.conf

#Habilitamos el módulo rewrtie
a2enmod rewrite

#Tengo que hacer un restart porque hemos habilitado un puerto nuevo (apache)
systemctl restart apache2

#imagen1 vemos como el sitio no es seguro
#imagen2 información del certificado

#Ahora mismo tengo un servidor apache que responde tanto al puerto
#80 y 443. Debemos conseguir que se haga una redirección automática al
#puerto 443 (que se cambie a https). Vamos a configurar para que cuando
#yo pida la url por http nos rediriga a https.

#Cambiando el archivo del virtualhost del puerto 80.
#Vamos a activar el modulo de reescritura de urls.
#%HTTPS% es una variable interana de apache.
#El codigo 300 es de redirecciones. y 301 que el recurso por http ya no existe
#tiene que irse al recurso nuevo por https

