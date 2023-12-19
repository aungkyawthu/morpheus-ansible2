#!/bin/bash

# Set your MariaDB credentials
DB_USER="root"
DB_PASSWORD=""

# Create the database
mysql -u$DB_USER  -e "CREATE DATABASE IF NOT EXISTS rolodex;"

# Create the table
mysql -u$DB_USER -e "USE rolodex; CREATE TABLE contacts (
  id INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  age INT(3) NOT NULL,
  email VARCHAR(100) NOT NULL,
  PRIMARY KEY (id)
);"