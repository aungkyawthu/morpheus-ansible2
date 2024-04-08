#!/bin/bash

# Stop firewalld
systemctl stop firewalld

# Disable SELinux (setenforce 0)
setenforce 0

# Install PHP and PHP MySQL extension
yum install -y php php-mysql

# Clone the repository
git clone https://github.com/aungkyawthu/php-quickstart.git

# Change to the directory
cd php-quickstart/src/

# Run PHP server in the background
nohup php -S 192.168.9.33:5900 > /dev/null 2>&1 &
