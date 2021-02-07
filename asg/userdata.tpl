#!/bin/bash
sudo mkdir -p /var/www/html/
sudo yum update -y
sudo yum install -y httpd
sudo service httpd start
sudo chkconfig httpd on
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo yum install -y mysql php php-mysql
sudo yum install git -y
git clone https://github.com/lamp-with-terraform/index.git
mv index/index.php /var/www/html/index.php
cd /var/www/html
sed -i 's/enter_the_name/${my_db_server_address}/' index.php
sudo service httpd restart
echo "USE mydb; CREATE TABLE counter (visits int(10) NOT NULL); INSERT INTO counter(visits) values(1);" | mysql -h ${my_db_server_address} -P 3306 -u lampuser -plamppassword
