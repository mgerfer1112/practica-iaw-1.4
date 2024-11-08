# practica-iaw-1.4

El objetivo de la siguiente práctica es conseguir crear un entorno seguro para un servidor web, con tal fin, configuraremos mediante certificados SSL en Apache el protocolo HTTPs. Esto requerirá de varios pasos como: 

1. Generación de un certificado autofirmado.
2. Configurar Apache para forzar conexiones HTTPs.
3. Subir nuestra web a internet mediante la IP y un DNS.

## Script setup_selfsigned_certificate.sh

El siguiente script automatiza la configuración de HTTPs en un servidor apache.

Las primeras líneas corresponden al hashbang, la importación de variables y habilitan la muestra en pantalla de lo que realiza el comando.

```
#!/bin/bash

source .env

set -ex
```

Como hemos mencionado, este script crea una clave SSL, a continuación mostraremos el comando completo para ello y posteriormente analizaremos palabara por palabra su significado:

```
 -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"
```

- x509 → Define el formato.
- nodes → Evita que el archivo clave esté encriptado.
- days 365 → Da una validez de 365 días al certificado.
- newkey rsa:2048 → Genera una clave RSA de 2048 bits con el certificado.
- keyout y out → Especifican la ubicación de la clave privada y certificado.
- subj → Añade detalles en el certificado, usando variables que definiremos posteriormente en el [.env](#env)

En este punto necesitaremos crear y habilitar un archivo de configuración que obligue al uso del puerto 443.

**Archivo de configuración default-ssl.conf**

```
  <VirtualHost *:443>
    #ServerName practica-https.local
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html

#Habilita al servidor para usar un certificado. 
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
```

Una vez instalado copiaremos el archivo al directorio de sitios disponibles de Apache.

```
cp ../conf/default-ssl.conf /etc/apache2/site-available
```

Podemos verificar que el archivo fue copiado con el siguiente comando:

```
cat /etc/apache2/site-available/default-ssl.conf
```

Posteriormente habilitaremos el archivo. Además, habilitaremos el modulo SSL en Apache.

```
sudo a2ensite default-ssl.conf
sudo a2enmod ssl
```
Habilitamos y activamos además el archivo 000-default.conf para que el servidor pueda manejar peticiones HTTP.

```
cp ../conf/000-default.conf /etc/apache2/sites-available

sudo a2ensite 000-default.conf
```

Habilitamos el módulo rewrite y reiniciamos apache.
```
a2enmod rewrite

systemctl restart apache2
```

A continuación podemos observar como es usado nuestro certificado y la información de este.

Como podemos ver nuestra clave está en funcionamiento, aunque no es considerada un sitio seguro dado que se trata de un certificado autofirmado y no está verificado por una autoridad certificadora. Es normal por ello observar la advertencia de seguridad.

![imagen1](https://github.com/user-attachments/assets/e4f07c85-09d2-489e-b709-f0f3581cb586)

![imagen2](https://github.com/user-attachments/assets/08a54c1b-af08-49e8-84b8-4326dc6ca40a)


## Archivo de variables .env

```
#configuramos las variables de entorno, de contraseña (sin $ y sin espacios)
PHPMYADMIN_APP_PASSWORD=password
DB_USER=usuario
DB_PASSWORD=password
DB_NAME=moodle
STATS_USERNAME=mgerfer1112 
STATS_PASSWORD=a

# Configuramos las variables con los datos que necesita el certificado
OPENSSL_COUNTRY="ES"
OPENSSL_PROVINCE="Almeria"
OPENSSL_LOCALITY="Almeria"
OPENSSL_ORGANIZATION="IES Celia"
OPENSSL_ORGUNIT="Departamento de Informatica"
OPENSSL_COMMON_NAME="practica-https.local"
OPENSSL_EMAIL="admin@iescelia.org"

```

Tras haber realizado esto podemos mediante páginas como [No-IP](https://my.noip.com/dynamic-dns) vincualr nuestra IP a un DNS para poder acceder sin necesidad de la IP.

![image](https://github.com/user-attachments/assets/f0c443d4-1f8d-4a43-b654-ed46fc10273b)
