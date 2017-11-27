#!/bin/bash

function exportBoolean {
    if [ "${!1}" = "**Boolean**" ]; then
            export ${1}=''
    else 
            export ${1}='Yes.'
    fi
}

exportBoolean LOG_STDOUT
exportBoolean LOG_STDERR

if [ $LOG_STDERR ]; then
    /bin/ln -sf /dev/stderr /var/log/apache2/error.log
else
	LOG_STDERR='No.'
fi

if [ $ALLOW_OVERRIDE == 'All' ]; then
    /bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf
fi

if [ $LOG_LEVEL != 'warn' ]; then
    /bin/sed -i "s/LogLevel\ warn/LogLevel\ ${LOG_LEVEL}/g" /etc/apache2/apache2.conf
fi

# enable php short tags:
/bin/sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.0/apache2/php.ini

# stdout server info:
if [ ! $LOG_STDOUT ]; then
cat << EOB
    
    *************************************************************
    *                                                           *
    *    Docker image: peter-hartmann/debian-lamp               *
    *    https://github.com/peter-hartmann/docker-debian-lamp   *
    *                                                           *
    *************************************************************

    SERVER SETTINGS
    ---------------
    · Redirect Apache access_log to STDOUT [LOG_STDOUT]: No.
    · Redirect Apache error_log to STDERR [LOG_STDERR]: $LOG_STDERR
    · Log Level [LOG_LEVEL]: $LOG_LEVEL
    · Allow override [ALLOW_OVERRIDE]: $ALLOW_OVERRIDE
    · PHP date timezone [DATE_TIMEZONE]: $DATE_TIMEZONE

EOB
else
    /bin/ln -sf /dev/stdout /var/log/apache2/access.log
fi

# Set PHP timezone
/bin/sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php/7.0/apache2/php.ini

echo "###### Starting Postfix"
# workaround https://linuxconfig.org/fatal-the-postfix-mail-system-is-already-running-solution
rm -f /var/spool/postfix/pid/master.pid
/usr/sbin/postfix start

if [ -d "/var/lib/mysql" ]; then chown -R mysql:mysql /var/lib/mysql/; fi #ensure mysql owns it even if mounted;
if [ -d "/var/log/mysql" ]; then chown -R mysql:mysql /var/log/mysql/; fi #ensure mysql owns it even if mounted;
if [ $(find /var/lib/mysql -maxdepth 0 -type d -empty 2>/dev/null) ]; then 
	echo "###### Initializing MariaDB data dir - it was empty"
	mysql_install_db
	service mysql start;
	mysql-secure-init.sh;
fi

echo "###### Starting MariaDB"
service mysql start
#  /usr/bin/mysqld --timezone=${DATE_TIMEZONE}&

# workaround https://serverfault.com/a/480890
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '`sed -n '/user *= *debian-sys-main/{n;s/password *= *//;x};${x;p}' /etc/mysql/debian.cnf`';FLUSH PRIVILEGES;"

echo "###### Starting Apache"
# workaround https://askubuntu.com/a/396048
echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
ln -s /etc/apache2/conf-available/servername.conf /etc/apache2/conf-enabled/servername.conf
service apache2 start

echo "###### Applying config"
cp -n config.sh /backup/ || true
/backup/config.sh

## Run Apache:
#if [ $LOG_LEVEL == 'debug' ]; then
#    /usr/sbin/apachectl -DFOREGROUND -k start -e debug
#else
#    &>/dev/null /usr/sbin/apachectl -DFOREGROUND -k start
#fi
