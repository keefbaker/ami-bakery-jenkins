#!/bin/bash
yum update -y
yum install nginx
systemctl enable nginx
systemctl start nginx