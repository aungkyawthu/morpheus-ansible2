#!/bin/bash

# Update package list
sudo apt update

# Install Apache2
sudo apt install -y apache2

# Enable and start the Apache service
sudo systemctl enable apache2
sudo systemctl start apache2

# Confirm Apache is running
sudo systemctl status apache2 --no-pager
