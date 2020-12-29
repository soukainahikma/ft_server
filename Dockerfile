FROM debian:buster
#install commands + nginx
RUN apt update && apt install -y nginx && apt -y install vim && apt -y install wget
RUN service nginx start
#install mysql
RUN apt install -y default-mysql-server
COPY ./srcs/requet.sql /requet.sql
RUN service mysql start && mysql -u root < "/requet.sql"
#install php
RUN apt-get install -y php-mbstring php-zip php-gd php-xml php-pear php-gettext php-cli php-fpm php-cgi php-mysql
RUN service php7.3-fpm start
#install phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-english.tar.gz
RUN tar -xzf phpMyAdmin-4.9.0.1-english.tar.gz
RUN rm phpMyAdmin-4.9.0.1-english.tar.gz
RUN mv phpMyAdmin-4.9.0.1-english/ ./var/www/html/phpmyadmin
RUN chmod 777 /var/www/html/
RUN chown -R www-data:www-data /var/www/html/
COPY ./srcs/config.inc.php ./var/www/html/phpmyadmin/config.inc.php
COPY ./srcs/default /etc/nginx/sites-available/default
RUN service php7.3-fpm restart
#install wordpress
RUN wget -c http://wordpress.org/latest.tar.gz
RUN tar xzf latest.tar.gz
RUN rm latest.tar.gz
RUN mv wordpress /var/www/html/wordpress
#    #chown -- change file owner and group( -R Change the user ID and/or the group ID for the file hierarchi)
RUN chown -R www-data:www-data /var/www/html/wordpress
RUN chmod -R 755 /var/www//html/wordpress
COPY ./srcs/wd_p.sql /wd_p.sql
RUN service mysql start && mysql -u root < "/wd_p.sql"
#get ssl certificate
RUN openssl req -subj "/C=MA/ST=KHOURIBGA/L=BJ/O=Yoki/CN=localhost" -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
COPY ./srcs/self-signed.conf /etc/nginx/snippets/self-signed.conf
COPY ./srcs/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

RUN service nginx restart 
RUN service mysql restart 
RUN service php7.3-fpm restart

#keep Docker container running after starting services
COPY ./srcs/script.sh /script.sh
RUN chmod 777 /script.sh
ENTRYPOINT ["/script.sh"]