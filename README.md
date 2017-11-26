peter-hartmann/lamp
===================

![docker_logo](https://raw.githubusercontent.com/peter-hartmann/docker-debian-lamp/master/docker_139x115.png)
Features:
 * Fork and incremental change of [flauria/lamp](https://github.com/fauria/docker-lamp)
 * Debian LAMP
 * Email support for PHP [mail()](http://php.net/manual/en/function.mail.php) and commandline via relayhost, e.g. use Gmail as relay host
 * Supports external MariaDB/MySql data volume, will be auto initialized if empty
 * Support for [Composer](https://getcomposer.org/) and [npm](https://www.npmjs.com/) package managers
 * No password for debian root and no password for mariadb/mysql root

Includes the following components:

 * Debian Jessie base image
 * Apache HTTP Server 2.4
 * MariaDB 10.0
 * Postfix 2.11
 * PHP 7
 * PHP modules
 	* php-bz2
	* php-cgi
	* php-cli
	* php-common
	* php-curl
	* php-dbg
	* php-dev
	* php-enchant
	* php-fpm
	* php-gd
	* php-gmp
	* php-imap
	* php-interbase
	* php-intl
	* php-json
	* php-ldap
	* php-mcrypt
	* php-mysql
	* php-odbc
	* php-opcache
	* php-pgsql
	* php-phpdbg
	* php-pspell
	* php-readline
	* php-recode
	* php-snmp
	* php-sqlite3
	* php-sybase
	* php-tidy
	* php-xmlrpc
	* php-xsl
 * Development tools
	* git
	* composer
	* npm / nodejs
	* vim
	* tree
	* nano
	* ftp
	* curl
	* expect

Building from [github](https://github.com/peter-hartmann/docker-debian-lamp).
----

Clone the repository, setup mail relay credentials, build the docker image, spawn a container, 
```bash
git clone https://github.com/peter-hartmann/docker-debian-lamp.git
nano docker-debian-lamp/assets/postfix-sasl_passwd
docker build -t peter-hartmann/debian-lamp docker-debian-lamp/
docker run -d --rm --name lamp -v $(pwd)/www/html:/var/www/html -v $(pwd)/lib/mysql:/var/lib/mysql -v $(pwd)/log/httpd:/var/log/httpd -v $(pwd)/log/mysql:/var/log/mysql peter-hartmann/debian-lamp
```
Get inside the container
```bash
docker exec -it lamp bash
```
Send email
```bash
sendmail name@domain.com <<EOF
from:your@gmail.com
reply-to:your@gmail.com
to:name@domain.com
subject:abc 1
EOF
```

Environment variables
----

This image uses environment variables to allow the configuration of some parameteres at run time:

* Variable name: LOG_STDOUT
* Default value: Empty string.
* Accepted values: Any string to enable, empty string or not defined to disable.
* Description: Output Apache access log through STDOUT, so that it can be accessed through the [container logs](https://docs.docker.com/reference/commandline/logs/).

----

* Variable name: LOG_STDERR
* Default value: Empty string.
* Accepted values: Any string to enable, empty string or not defined to disable.
* Description: Output Apache error log through STDERR, so that it can be accessed through the [container logs](https://docs.docker.com/reference/commandline/logs/).

----

* Variable name: LOG_LEVEL
* Default value: warn
* Accepted values: debug, info, notice, warn, error, crit, alert, emerg
* Description: Value for Apache's [LogLevel directive](http://httpd.apache.org/docs/2.4/en/mod/core.html#loglevel).

----

* Variable name: ALLOW_OVERRIDE
* Default value: All
* All, None
* Accepted values: Value for Apache's [AllowOverride directive](http://httpd.apache.org/docs/2.4/en/mod/core.html#allowoverride).
* Description: Used to enable (`All`) or disable (`None`) the usage of an `.htaccess` file.

----

* Variable name: DATE_TIMEZONE
* Default value: UTC
* Accepted values: Any of PHP's [supported timezones](http://php.net/manual/en/timezones.php)
* Description: Set php.ini default date.timezone directive and sets MariaDB as well.

Exposed port and volumes
----

The image exposes ports `80` and `3306`, and exports four volumes:

* `/var/log/httpd`, containing Apache log files.
* `/var/log/mysql` containing MariaDB log files.
* `/var/www/html`, used as Apache's [DocumentRoot directory](http://httpd.apache.org/docs/2.4/en/mod/core.html#documentroot).
* `/var/lib/mysql`, where MariaDB data files are stores.


The user and group owner id for the DocumentRoot directory `/var/www/html` are both 33 (`uid=33(www-data) gid=33(www-data) groups=33(www-data)`).

The user and group owner id for the MariaDB directory `/var/log/mysql` are 105 and 108 repectively (`uid=105(mysql) gid=108(mysql) groups=108(mysql)`).

Use cases
----

#### Create a temporary container for testing purposes:

```
docker run -it --rm peter-hartmann/debian-lamp bash
```
Then in container run
```
run-lamp.sh
```

#### Create a temporary container to debug a web app:

```
docker run --rm -p 8080:80 -e LOG_STDOUT=true -e LOG_STDERR=true -e LOG_LEVEL=debug -v /my/data/directory:/var/www/html peter-hartmann/debian-lamp
```

#### Create a container linking to another [MySQL container](https://registry.hub.docker.com/_/mysql/):

```
docker run -d --link my-mysql-container:mysql -p 8080:80 -v /my/data/directory:/var/www/html -v /my/logs/directory:/var/log/httpd --name my-lamp-container peter-hartmann/debian-lamp
```

#### Get inside a running container and open a MariaDB console:

```
docker exec -it my-lamp-container bash
mysql -u root
```
