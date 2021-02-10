#!/bin/bash
yum update -y
sudo yum install -y amazon-linux-extras
amazon-linux-extras enable nginx1
yum install -y nginx
yum install -y java-1.8.0-openjdk
systemctl enable nginx
systemctl start nginx
