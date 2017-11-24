peter-hartmann/lamp
===================

![docker_logo](https://raw.githubusercontent.com/peter-hartmann/docker-debian-lamp/master/docker_139x115.png)
Features:
 * Folk and incremental change to flauria/lamp
 * Debian LAMP stack
 * Popular PHP modules
 * Support for [Composer](https://getcomposer.org/) and [npm](https://www.npmjs.com/) package managers
 * Postfix setup as relayhost, ideal for sending email through gmail from PHP [mail()](http://php.net/manual/en/function.mail.php) function, or commanline sendmail
 * No password for debian root and mariadb/mysql root
 * DB data exposed as valume, will be initialized when data folder is empty

Includes the following components:

 * Debian Jassie base image.
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

Todo: Installation from [Docker registry hub](https://registry.hub.docker.com/u/peter-hartmann/lamp/).
----

Todo: You can download the image using the following command:

```bash
docker pull peter-hartmann/debian-lamp
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
	docker run -i -t --rm fauria/lamp bash
```

#### Create a temporary container to debug a web app:

```
	docker run --rm -p 8080:80 -e LOG_STDOUT=true -e LOG_STDERR=true -e LOG_LEVEL=debug -v /my/data/directory:/var/www/html fauria/lamp
```

#### Create a container linking to another [MySQL container](https://registry.hub.docker.com/_/mysql/):

```
	docker run -d --link my-mysql-container:mysql -p 8080:80 -v /my/data/directory:/var/www/html -v /my/logs/directory:/var/log/httpd --name my-lamp-container fauria/lamp
```

#### Get inside a running container and open a MariaDB console:

```
	docker exec -i -t my-lamp-container bash
	mysql -u root
```
