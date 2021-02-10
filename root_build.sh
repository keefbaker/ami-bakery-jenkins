#!/bin/bash
yum update -y
yum install -y amazon-linux-extras java-1.8.0-openjdk
amazon-linux-extras enable nginx1
yum install -y nginx
systemctl enable nginx
systemctl start nginx
