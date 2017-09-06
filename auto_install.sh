#!/bin/bash - 


#Env prepare:
echo "[*] Environment preparing..."


#Network checking and get the basic rpm packages 
#ping -c 1 www.baidu.com > /dev/null 2>&1
#if [ $? -eq 0 ];then
#	echo "[+] Network is normal, downloading the basic packages..."
#	yum -y install lrzsz wget vim bash-completion
#	wget -O /$HOME/php-5.6.31.tar.gz http://php.net/get/php-5.6.31.tar.gz/from/this/mirror 
#	wget -O /$HOME/mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz 
#	wget -O /$HOME/nginx-1.10.3.tar.gz http://nginx.org/download/nginx-1.10.3.tar.gz 

#else
#	echo "[-] Notwork Error. Please check your network."
#	exit
#fi

#echo "[+] Download complete..."



function mysql5.6_i() {

#[Mysql]
cd $HOME

echo "[*] Start installing MySQL-5.6"
yum -y install autoconf libaio-devel

useradd -r -s /sbin/nologin -M mysql
tar -xf mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz
mv ./mysql-5.6.36-linux-glibc2.5-x86_64 /usr/local/mysql-5.6
ln -s /usr/local/mysql-5.6 /usr/local/mysql

mkdir -p /usr/local/mysql/logs
touch /usr/local/mysql/logs/error.log
chown -R mysql.mysql /usr/local/mysql/data      
chown -R mysql.mysql /usr/local/mysql/logs

#Initialize mysql
/usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/data --basedir=/usr/local/mysql       

#Edit configure files and make soft links
mv /usr/local/mysql/my.cnf /usr/local/mysql/my.cnf.bak
cat > /usr/local/mysql/my.cnf <<EOF
[mysqld]
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
port = 33065
socket = /tmp/mysql.sock
pid-file = /usr/local/mysql/logs/mysql.pid
log-error = /usr/local/mysql/logs/error.log
character_set_server = utf8

[mysqld_safe]
log-error = /usr/local/mysql/logs/error.log
pid-file = /usr/local/mysql/logs/mysql.pid
EOF
ln -s /usr/local/mysql/bin/mysql /usr/bin
ln -s /usr/local/mysql/bin/mysqladmin /usr/bin
ln -s /usr/local/mysql/bin/mysqldump /usr/bin

#To start with mysql
cat > /usr/lib/systemd/system/mysql.service <<EOF
[Unit]
Description=mysql
After=

[Service]
Type=forking
ExecStart=/usr/local/mysql/support-files/mysql.server start
ExecReload=/usr/local/mysql/support-files/mysql.server restart
ExecStop=/usr/local/mysql/support-files/mysql.server stop
PrivateTmp=false

[Install]
WantedBy=multi-user.target
EOF

#Start and enable mysql
systemctl start mysql.service

/usr/local/mysql/bin/mysqladmin -u root password 'P@ssw0rd'

if [ $? -eq 0 ];then
    systemctl enable mysql.service
    echo "[+] Mysql has changed the root password. Do remember the password: P@ssw0rd"
    echo "[+] Change the password whenever you want. "
    echo " `date '+%F %T'`  mysql5.6 installed successfully!   The password for root@localhost is 'P@ssw0rd'"  >>${HOME}/install_info

else
    echo " `date '+%F %T'`  mysql5.6 installed failed!"   >>${HOME}/install_info
    exit
fi

}




function mysql5.7_i() {

#[Mysql]
cd $HOME

echo "[*] Start installing MySQL-5.7"
yum -y install autoconf libaio-devel

useradd -r -s /sbin/nologin -M mysql
tar -xf mysql-5.7.19-linux-glibc2.12-x86_64.tar.gz
mv ./mysql-5.7.19-linux-glibc2.12-x86_64 /usr/local/mysql-5.7
ln -s /usr/local/mysql-5.7 /usr/local/mysql

mkdir -p /usr/local/mysql/logs
mkdir -p /usr/local/mysql/data
touch /usr/local/mysql/logs/error.log
chown -R mysql.mysql /usr/local/mysql/data      
chown -R mysql.mysql /usr/local/mysql/logs

#Initialize mysql
/usr/local/mysql/bin/mysqld --user=mysql --datadir=/usr/local/mysql/data --basedir=/usr/local/mysql --initialize &> /usr/local/mysql/readme

#Edit configure files and make soft links
#mv /usr/local/mysql/my.cnf /usr/local/mysql/my.cnf.bak
cat > /usr/local/mysql/my.cnf <<EOF
[mysqld]
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
port = 3306
socket = /tmp/mysql.sock
pid-file = /usr/local/mysql/logs/mysql.pid
log-error = /usr/local/mysql/logs/error.log
character_set_server = utf8

[mysqld_safe]
log-error = /usr/local/mysql/logs/error.log
pid-file = /usr/local/mysql/logs/mysql.pid
EOF
ln -s /usr/local/mysql/bin/mysql /usr/bin
ln -s /usr/local/mysql/bin/mysqladmin /usr/bin
ln -s /usr/local/mysql/bin/mysqldump /usr/bin

#To start with mysql
cat > /usr/lib/systemd/system/mysql.service <<EOF
[Unit]
Description=mysql
After=

[Service]
Type=forking
ExecStart=/usr/local/mysql/support-files/mysql.server start
ExecReload=/usr/local/mysql/support-files/mysql.server restart
ExecStop=/usr/local/mysql/support-files/mysql.server stop
PrivateTmp=false

[Install]
WantedBy=multi-user.target
EOF

#Start and enable mysql
systemctl start mysql.service
if [ $? -eq 0 ];then
	echo "`date '+%F %T'`  mysql5.7 install successfully! The password for root@localhost in file '/usr/local/mysql/readme'" >> ${HOME}/install_info
	systemctl enable mysql.service
else
	echo "`date '+%F %T'`  mysql5.7 install failed!" >>  ${HOME}/install_info
fi
}





function nginx1.12_i() {

#[Nginx]
#Install development packages
echo "[*] Start installing Nginx-1.12.1..."
cd $HOME
yum -y install gcc pcre-devel openssl-devel

#http://www.zlib.net/zlib-1.2.11.tar.gz
tar -xf zlib-1.2.11.tar.gz
mv ./zlib-1.2.11 /usr/local/src

tar -xf nginx-1.12.1.tar.gz
cd nginx-1.12.1

cp src/core/nginx.h src/core/nginx.h.bak
cp src/http/ngx_http_header_filter_module.c src/http/ngx_http_header_filter_module.c.bak
cp src/http/ngx_http_special_response.c src/http/ngx_http_special_response.c.bak
sed -i 's/#define NGINX_VERSION      "1.10.3"/#define NGINX_VERSION      "2.4.6"/g' src/core/nginx.h 									# 软件版本号：1.12.0（约13行）
sed -i 's%#define NGINX_VER          "nginx/" NGINX_VERSION%#define NGINX_VER          "Apache/" NGINX_VERSION%g' src/core/nginx.h  	# 软件名称：nginx（约14行）
sed -i 's/#define NGINX_VAR          "NGINX"/#define NGINX_VAR          "Apache"/g' src/core/nginx.h 		 							# 软件名称：nginx（约22行）
sed -i 's/Server: nginx/Server: Apache/g' src/http/ngx_http_header_filter_module.c   													# 软件名称：nginx（约44行）
sed -i 's#<center>nginx</center>#<center>Apache</center>#g' src/http/ngx_http_special_response.c  								      	# 软件名称：nginx（约36行）

#Make install
./configure \
--prefix=/usr/local/nginx-1.12 \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_sub_module \
--with-http_stub_status_module \
--with-pcre-jit \
--with-pcre \
--with-zlib=/usr/local/src/zlib-1.2.11 \
--with-http_secure_link_module \
--with-http_gzip_static_module
make && make install

ln -s /usr/local/nginx-1.12 /usr/local/nginx
ln -s /usr/local/nginx/sbin/nginx /usr/bin

#To support php:
cat > /usr/local/nginx/conf/nginx.conf <<EOF

worker_processes  auto;
user  nginx;
worker_rlimit_nofile 51200;

events {
    use epoll;
    worker_connections  51200;
}

http {
    limit_req_zone \$binary_remote_addr zone=req:200m rate=300r/s;
    limit_req zone=req burst=50;
    client_body_buffer_size 32k;
    client_header_buffer_size 2k;
    client_max_body_size 2m;
    default_type application/octet-stream;
    log_not_found off;
    server_tokens off;
    include       mime.types;
    gzip on;
    gzip_min_length  1k;
    gzip_buffers     4 16k;
    gzip_http_version 1.0;
    gzip_comp_level 2;
    gzip_types       text/plain text/css text/xml text/javascript application/x-javascript application/xml application/rss+xml application/xhtml+xml application/atom_xml;
    gzip_vary on;
    log_format  access  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
              '\$status \$body_bytes_sent "\$http_referer" '
              '"\$http_user_agent" /\$http_x_forwarded_for';

    server {
        listen 80;
        server_name 127.0.0.1;
        root /home/wwwroot/;
        index index.php index.html index.htm;

        location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            fastcgi_param  PHP_VALUE        open_basedir=\$document_root:/tmp/:/proc/;
            include        fastcgi_params;
        }
	    location /ngx_status {
            allow 127.0.0.1;
            stub_status on;
	    access_log off;
        }

        location /phpfpm_status {
            include fastcgi_params;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_param SCRIPT_FILENAME \$fastcgi_script_name;
	    access_log off;
	}	 
	} 
	


    server {
		listen 80 default_server;
        server_name _;
        return 444;
	}
	
    include vhost/*.conf;
}
EOF


#create virtual host config file template
mkdir -p /usr/local/nginx/conf/vhost
touch /usr/local/nginx/conf/vhost/virtual-host.temp

cat > /usr/local/nginx/conf/vhost/virtual-host.temp <<eof
server {
    server_name _;
    listen 8080;
    index index.php index.html index.htm;
    root /home/wwwroot/website/public;

    location / {
		if (!-e $request_filename) {
		rewrite  ^(.*)$  /index.php?s=/$1  last;
		break;
    }
    }

    location ~ \.php\$ {
		fastcgi_pass   127.0.0.1:9000;
		fastcgi_index  index.php;
		fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
		fastcgi_param  PHP_VALUE         open_basedir=/home/wwwroot/website/:/tmp/:/proc/;
		include        fastcgi_params;
        }
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
		expires   1s;
    }

    location ~ .*\.(js|css)?$ {
		expires   1s;
    }

    access_log  /home/wwwlog/website/access.log access;
    error_log  /home/wwwlog/website/error.log error;
}
eof



mkdir -p /home/wwwroot

#Start System with nginx
cat > /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx - high performance web server
After=

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target
EOF

#check config
/usr/local/nginx/sbin/nginx -t
if [ $? -eq 0 ];then
	systemctl start nginx.service
	systemctl enable nginx.service

	echo "`date '+%F %T'`   nginx1.12 installed successfully!" >> ${HOME}/install_info
else
	echo "`date '+%F %T'`   nginx1.12 installed failed!" >> ${HOME}/install_info
	exit
fi

}


function php7.1_i() {

#[PHP]
#Install development packages
echo "[*] Start installing PHP from source package..."
cd $HOME
yum -y install epel-release
yum -y install gcc libxml2-devel openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel

#ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/libmcrypt/libmcrypt-2.5.7.tar.gz
# tar -xf libmcrypt-2.5.7.tar.gz
# cd libmcrypt-2.5.7
# ./configure
# make && make install

cd $HOME
tar -xf php-7.1.7.tar.gz
cd php-7.1.7

#Make install
./configure \
--prefix=/usr/local/php-7.1 \
--with-config-file-path=/usr/local/php-7.1/etc \
--enable-fpm \
--with-pdo_sqlite \
--with-iconv \
--enable-ftp \
--with-sqlite3 \
--enable-mbstring \
--enable-sockets \
--enable-zip \
--enable-soap \
--enable-bcmath \
--enable-sockets \
--with-gettext \
--with-openssl \
--with-zlib \
--with-curl \
--with-gd \
--with-jpeg-dir \
--with-png-dir \
--with-freetype-dir \
--with-mcrypt=/usr/local \
--with-mhash \
--with-libdir=/lib \
--enable-opcache \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--without-pear \
--disable-fileinfo \
--with-fpm-user=nginx \
--with-fpm-group=nginx

make && make install

#Edit PHP configure files
ln -s /usr/local/php-7.1 /usr/local/php
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp ./php.ini-production /usr/local/php/etc/php.ini

cp /usr/local/php/etc/php.ini /usr/local/php/etc/php.ini.bak
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/disable_functions =/disable_functions = dl,eval,assert,exec,popen,system,passthru,shell_exec,escapeshellarg,escapeshellcmd,proc_close,proc_open/g' /usr/local/php/etc/php.ini 																													  # 禁用列出的php函数
sed -i 's/request_order = "GP"/request_order = "CGP"/g' /usr/local/php/etc/php.ini 											# 增加安全性
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini												# 增加安全性
sed -i 's#;date.timezone =#date.timezone = Asia/Chongqing#g' /usr/local/php/etc/php.ini 									# 设置时区
sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/php/etc/php.ini 													# 关闭版本信息
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini                                            # 允许使用代码开始标志的缩写形式
sed -i 's#;error_log = php_errors.log#error_log = /usr/local/php/var/log/php_errors.log#g' /usr/local/php/etc/php.ini       # 错误日志路径
sed -i 's#;error_log = syslog#error_log = /usr/local/php/var/log/php_errors.log#g' /usr/local/php/etc/php.ini               # 错误日志路径
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/g' /usr/local/php/etc/php.ini 											# 打开远程打开（禁止）
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /usr/local/php/etc/php.ini                                  # 上传文件大小限制
sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/g' /usr/local/php/etc/php.ini                                          # 允许本地PHP文件通过调用URL重写来打开和关闭写权限
sed -i 's#;slowlog = log/$pool.log.slow#slowlog = var/log/$pool.log.slow#g' /usr/local/php/etc/php-fpm.d/www.conf				# 修改日志路径
sed -i 's/;request_slowlog_timeout = 0/request_slowlog_timeout = 5/g' /usr/local/php/etc/php-fpm.d/www.conf				# 跟踪执行时间达到或超过5s的脚本
sed -i 's#;pm.status_path = /status#pm.status_path = /phpfpm_status#g' /usr/local/php/etc/php-fpm.d/www.conf                  # php状态页面
sed -i 's/pm.max_children = 5/pm.max_children = 300/g' /usr/local/php/etc/php-fpm.d/www.conf                                  # php动态方式下进程最大数量
sed -i 's/pm.start_servers = 2/pm.start_servers = 5/g' /usr/local/php/etc/php-fpm.d/www.conf                                     # php动态方式下起始时的进程数量
sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g' /usr/local/php/etc/php-fpm.d/www.conf                              # php动态方式下空闲状态最小php进程数量
sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 8/g' /usr/local/php/etc/php-fpm.d/www.conf                              # php动态方式下空闲状态最大php进程数量

echo "[opache]" >> /usr/local/php/etc/php.ini
echo "zend_extension=opcache.so" >> /usr/local/php/etc/php.ini
echo "opcache.memory_consumption=128" >> /usr/local/php/etc/php.ini
echo "opcache.interned_strings_buffer=8" >> /usr/local/php/etc/php.ini
echo "opcache.max_accelerated_files=4000" >> /usr/local/php/etc/php.ini
echo "opcache.revalidate_freq=60" >> /usr/local/php/etc/php.ini
echo "opcache.fast_shutdown=1" >> /usr/local/php/etc/php.ini

#To start with system
cat > /usr/lib/systemd/system/php-fpm.service <<EOF
[Unit]
Description=php
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/php/sbin/php-fpm

[Install]
WantedBy=multi-user.target

EOF

ln -s /usr/local/php/sbin/php-fpm /usr/bin

#check config
/usr/local/php/sbin/php-fpm -t
if [ $? -eq 0 ];then

	systemctl start php-fpm.service
	systemctl enable php-fpm.service

	echo "`date '+%F %T'`  php7.1 installed successfully!" >> ${HOME}/install_info
else
	echo " `date '+%F %T'`  php-fpm test failed. Please check your config file." >> ${HOME}/install_info
	exit
fi

}





function php5.6_i() {

#[PHP]
#Install development packages
echo "[*] Start installing PHP from source package..."
cd $HOME
yum -y install epel-release
yum -y install gcc libxml2-devel openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel

cd $HOME
tar -xf php-5.6.31.tar.gz
cd php-5.6.31

#Make install
./configure \
--prefix=/usr/local/php-5.6 \
--with-config-file-path=/usr/local/php-5.6/etc \
--enable-fpm \
--with-pdo_sqlite \
--with-iconv \
--enable-ftp \
--with-sqlite3 \
--enable-mbstring \
--enable-sockets \
--enable-zip \
--enable-soap \
--enable-bcmath \
--enable-sockets \
--with-gettext \
--with-openssl \
--with-zlib \
--with-curl \
--with-gd \
--with-jpeg-dir \
--with-png-dir \
--with-freetype-dir \
--with-mcrypt=/usr/local \
--with-mhash \
--with-libdir=/lib \
--enable-opcache \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--without-pear \
--disable-fileinfo \
--with-fpm-user=nginx \
--with-fpm-group=nginx

make && make install

#Edit PHP configure files
ln -s /usr/local/php-5.6 /usr/local/php
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp ./php.ini-production /usr/local/php/etc/php.ini

cp /usr/local/php/etc/php.ini /usr/local/php/etc/php.ini.bak
cp /usr/local/php/etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf.bak
sed -i 's/disable_functions =/disable_functions = dl,eval,assert,exec,popen,system,passthru,shell_exec,escapeshellarg,escapeshellcmd,proc_close,proc_open/g' /usr/local/php/etc/php.ini 																													  # 禁用列出的php函数
sed -i 's/request_order = "GP"/request_order = "CGP"/g' /usr/local/php/etc/php.ini 											# 增加安全性
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini												# 增加安全性
sed -i 's#;date.timezone =#date.timezone = Asia/Chongqing#g' /usr/local/php/etc/php.ini 									# 设置时区
sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/php/etc/php.ini 													# 关闭版本信息
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini                                            # 允许使用代码开始标志的缩写形式
sed -i 's#;error_log = php_errors.log#error_log = /usr/local/php/var/log/php_errors.log#g' /usr/local/php/etc/php.ini       # 错误日志路径
sed -i 's#;error_log = syslog#error_log = /usr/local/php/var/log/php_errors.log#g' /usr/local/php/etc/php.ini               # 错误日志路径
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/g' /usr/local/php/etc/php.ini 											# 打开远程打开（禁止）
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /usr/local/php/etc/php.ini                                  # 上传文件大小限制
sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/g' /usr/local/php/etc/php.ini                                          # 允许本地PHP文件通过调用URL重写来打开和关闭写权限
sed -i 's#;slowlog = log/$pool.log.slow#slowlog = var/log/$pool.log.slow#g' /usr/local/php/etc/php-fpm.conf 				# 修改日志路径
sed -i 's/;request_slowlog_timeout = 0/request_slowlog_timeout = 5/g' /usr/local/php/etc/php-fpm.conf 						# 跟踪执行时间达到或超过5s的脚本
sed -i 's#;pm.status_path = /status#pm.status_path = /phpfpm_status#g' /usr/local/php/etc/php-fpm.conf                      # php状态页面
sed -i 's/pm.max_children = 5/pm.max_children = 300/g' /usr/local/php/etc/php-fpm.conf                                      # php动态方式下进程最大数量
sed -i 's/pm.start_servers = 2/pm.start_servers = 5/g' /usr/local/php/etc/php-fpm.conf                                      # php动态方式下起始时的进程数量
sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g' /usr/local/php/etc/php-fpm.conf                              # php动态方式下空闲状态最小php进程数量
sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 8/g' /usr/local/php/etc/php-fpm.conf                              # php动态方式下空闲状态最大php进程数量

echo "[opache]" >> /usr/local/php-5.6/etc/php.ini
echo "zend_extension=opcache.so" >> /usr/local/php-5.6/etc/php.ini
echo "opcache.memory_consumption=128" >> /usr/local/php-5.6/etc/php.ini
echo "opcache.interned_strings_buffer=8" >> /usr/local/php-5.6/etc/php.ini
echo "opcache.max_accelerated_files=4000" >> /usr/local/php-5.6/etc/php.ini
echo "opcache.revalidate_freq=60" >> /usr/local/php-5.6/etc/php.ini
echo "opcache.fast_shutdown=1" >> /usr/local/php-5.6/etc/php.ini
#echo "extension=curl.so" >> /usr/local/php-5.6/etc/php.ini
#echo "extension=gd.so" >> /usr/local/php-5.6/etc/php.ini
#echo "extension=mbstring.so" >> /usr/local/php-5.6/etc/php.ini
#echo "extension=pdo_mysql.so" >> /usr/local/php-5.6/etc/php.ini
#echo "extension=mysqli.so" >> /usr/local/php-5.6/etc/php.ini


#To start with system
cat > /usr/lib/systemd/system/php-fpm.service <<EOF
[Unit]
Description=php
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/php/sbin/php-fpm

[Install]
WantedBy=multi-user.target

EOF

ln -s /usr/local/php/sbin/php-fpm /usr/bin

#check config
/usr/local/php/sbin/php-fpm -t
if [ $? -eq 0 ];then

	systemctl start php-fpm.service
	systemctl enable php-fpm.service

	echo "`date '+%F %T'`  php5.6 installed successfully!" >> ${HOME}/install_info
else
	echo "`date '+%F %T'`  php-fpm test failed. Please check your config file." >> ${HOME}/install_info
	exit
fi

}



function memcached_i() {
#安装libmemcached
cd $HOME
yum install gcc-c++ -y
tar -xf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18
./configure --prefix=/usr/local/libmemcached-1.0
make && make install
ln -s /usr/local/libmemcached-1.0 /usr/local/libmemcached

#安装php memcached扩展
cd $HOME
tar -xf memcached-2.2.0.tgz
cd memcached-2.2.0
#autoconf
/usr/local/php/bin/phpize
./configure --enable-memcached --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached --disable-memcached-sasl
make && make install
##position
echo 'extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/"' >> /usr/local/php/etc/php.ini
echo 'extension= "memcached.so"' >> /usr/local/php/etc/php.ini

#安装memcached
cd $HOME
yum install libevent-devel -y
tar -xvf memcached-1.5.1.tar.gz
cd memcached-1.5.1
./configure --prefix=/usr/local/memcached-1.5
make && make install

/usr/local/memcached-1.5/bin/memcached -d -c10240 -m 64 -uroot
if [ $? -eq 0 ];then
	echo "`date '+%F %T'`  memcached installed successfully!" >> ${HOME}/install_info
else
	echo "`date '+%F %T'`  memcached test failed. Please check your config file." >> ${HOME}/install_info
	exit
fi

ln -s /usr/local/memcached-1.5 /usr/local/memcached
echo "/usr/local/memcached-1.5/bin/memcached -d -c10240 -m 64 -uroot" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local


}






function fail2ban_i() {
#安装epel源
yum install epel-release -y &>/dev/null

#安装fail2ban
yum install fail2ban fail2ban-hostsdeny -y

mv /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak

cat > /etc/fail2ban/jail.conf <<eof
[DEFAULT]
ignoreip = 127.0.0.1
bantime = 3600
findtime = 600
maxretry = 5

[ssh]
enabled = true
filter  = sshd
action = hostsdeny
logpath = /var/log/secure
backend = auto
eof

systemctl start fail2ban
if [ $? -eq 0 ] ;then
	echo "`date '+%F %T'`  fail2ban install successfully!" >> ${HOME}/install_info
	systemctl enable fail2ban &>/dev/null
else
	echo "`date '+%F %T'`  fail2ban install failed!" >> ${HOME}/install_info
fi
}



function zabbix-agent_i() {
cd $HOME
uname -r | grep "x86_64" && wget "http://repo.zabbix.com/zabbix/3.2/rhel/6/x86_64/zabbix-agent-3.2.7-1.el6.x86_64.rpm" || wget "http://repo.zabbix.com/zabbix/3.2/rhel/6/i386/zabbix-agent-3.2.7-1.el6.i686.rpm"
agent=`ls | grep "zabbix-agent"`
rpm -ivh $agent
systemctl start zabbix-agent
if [ $? -eq 0 ] ;then
	echo "`date '+%F %T'`  zabbix-agent install successfully!" >> ${HOME}/install_info
	systemctl enable zabbix-agent &>/dev/null
else
	echo "`date '+%F %T'`  zabbix-agent install failed!" >> ${HOME}/install_info
fi
}



function subversion_i() {
	yum install subversion -y
	mkdir -p /home/svn
	svnserve -d -r /home/svn
	svnadmin create /home/svn/test
	cd /home/svn/test
	
#config svn conf	
	cd conf
	#svnserve.conf
	sed -i "s/# anon-access = read/anon-access = none/g" svnserve.conf
	sed -i "s/# auth-access = write/auth-access = write/g" svnserve.conf
	sed -i "s/# password-db = passwd/password-db = passwd/g" svnserve.conf
	sed -i "s/# authz-db = authz/authz-db = authz/g" svnserve.conf
	#passwd
	echo "test = 123" >> passwd
	#authz
	echo "[test:/]" >> authz 
	echo "admin = rw" >> authz 
	
#Create a sync site directory
	cd /home/svn/test/hooks
	cp post-commit.tmpl post-commit
	sed '$d' post-commit
	echo "export LANG="zh_CN.UTF-8"" >>post-commit
	echo "svn update /usr/local/nginx/html/ --username test --password 123 --no-auth-cache" >> post-commit
	chmod +x post-commit
	
	cd $HOME
	svnserve -d -r /home/svn
	svn checkout svn://127.0.0.1/test  /usr/local/nginx/html --username=test --password=123
	if [ $? -eq 0 ];then
		echo "`date '+%F %T'`   subversion installed successfully!"  >>  ${HOME}/install_info
		echo "/usr/bin/svnserve -d -r /home/svn" >> /etc/rc.d/rc.local
		chmod +x /etc/rc.d/rc.local
	else
		echo "`date '+%F %T'`   subversion installed failed!"  >>  ${HOME}/install_info
	fi
	
}





a=$#
yum -y install lrzsz wget vim bash-completion mlocate
while  [ $a != 0 ] 
do
    case $1 in 
        "nginx1.12")
            id nginx
            if [ $? -ne 0 ];then
                useradd -M -r -s /usr/nologin nginx
                ${1}_i;
            else
                ${1}_i;  
            fi
        ;;         

        "php7.1"|"php5.6")
            id nginx
            if [ $? -ne 0 ];then
                useradd -M -r -s /usr/nologin nginx
                ${1}_i;
            else
               ${1}_i;  
            fi
        ;;         

        "mysql5.6"|"mysql5.7")
            ${1}_i;
        ;;
		
		"fail2ban")
			fail2ban_i;
		;;
		
		"zabbix-agent")
			zabbix-agent_i;
		;;
		
		"svn")
			subversion_i;
		;;
		
		"memcached")
			memcached_i;
		;;
		
		*)
		echo "输入有误"
    esac

    a=$[a-1]
    shift
done
