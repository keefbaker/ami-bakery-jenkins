#!/bin/bash
yum update -y
sudo yum install -y amazon-linux-extras
amazon-linux-extras nginx1
yum install nginx
systemctl enable nginx
systemctl start nginx
