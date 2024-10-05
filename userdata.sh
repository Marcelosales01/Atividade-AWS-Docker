#!/bin/bash

yum update -y

amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user

curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

systemctl enable docker

yum install -y nfs-utils amazon-efs-utils

mkdir /mnt/efs
mount -t efs <Seu_File_System_Id> /mnt/efs
echo '<Seu_File_System_Id>:/ /mnt/efs efs defaults,_netdev 0 0' >> /etc/fstab

mkdir -p /mnt/efs/wordpress
chown -R ec2-user:ec2-user /mnt/efs/wordpress
chmod -R 775 /mnt/efs/wordpress

cat <<EOF > /home/ec2-user/docker-compose.yml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: <Seu_Endpoint_RDS>
      WORDPRESS_DB_USER: <Seu_User_RDS>
      WORDPRESS_DB_PASSWORD: <Sua_senha_RDS>
      WORDPRESS_DB_NAME: <Seu_Database_Name_RDS>
    volumes:
      - /mnt/efs/wordpress:/var/www/html
EOF

chown ec2-user:ec2-user /home/ec2-user/docker-compose.yml

cd /home/ec2-user
docker-compose up -d