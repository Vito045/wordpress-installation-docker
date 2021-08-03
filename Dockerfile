FROM centos:7

EXPOSE 80

RUN yum install -y httpd mariadb mariadb-server epel-release yum-utils http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN CURREENT_MYSQL_PASSWORD="password"
RUN echo 'root:${CURRENT_MYSQL_PASSWORD}' | chpasswd
RUN systemctl enable httpd.service
RUN systemctl start mariadb 
RUN SECURE_MYSQL=$(expect -c "set timeout 3;spawn mysql_secure_installation;expect \"Enter current password for root (enter for none):\";send \"$CURRENT_MYSQL_PASSWORD\r\";expect \"root password?\";send \"y\r\";expect \"New password:\";send \"$NEW_MYSQL_PASSWORD\r\";expect \"Re-enter new password:\";send \"$NEW_MYSQL_PASSWORD\r\";expect \"Remove anonymous users?\";send \"y\r\";expect \"Disallow root login remotely?\";send \"y\r\";expect \"Remove test database and access to it?\";send \"y\r\";expect eof")
RUN echo ${SECURE_MYSQL}
RUN systemctl enable mariadb.service
RUN mysql -u root -p --execute="CREATE DATABASE wordpress; GRANT ALL PRIVILEGES on wordpress.* to 'wordpress_user'@'localhost' identified by 'wordpress_pw'; FLUSH PRIVILEGES;"

WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz \
    && tar xvzf latest.tar.gz \
    && mv /var/www/html/wordpress/* /var/www/html \
    && yum-config-manager --enable remi-php70 \
    && yum -y install php php-mysql \
    && mv wp-config-sample.php wp-config.php \
    && sed -i "s|'database_name_here'|'wordpress'|" wp-config.php \
    && sed -i "s|'username_here'|'wordpress_user'|" wp-config.php \
    && sed -i "s|'password_here'|'wordpress_pw'|" wp-config.php \
    && systemctl restart httpd




