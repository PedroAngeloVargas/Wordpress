#!/bin/bash
sudo su

EFS_ID=""
DB_HOST=""
DB_NAME=""
DB_PASSWORD=""
DB_USER=""

yum update -y

yum install -y docker nfs-utils
amazon-linux-extras enable docker

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

systemctl start docker
systemctl enable docker

usermod -aG docker ec2-user

mkdir -p /mnt/efs_wordpress

mount -t nfs4 -o nfsvers=4.1 ${EFS_ID}.efs.us-east-1.amazonaws.com:/ /mnt/efs_wordpress

echo "${EFS_ID}.efs.us-east-1.amazonaws.com:/ /mnt/efs_wordpress nfs4 defaults,_netdev 0 0" >> /etc/fstab

chown ec2-user:ec2-user /mnt/efs_wordpress
chmod 775 /mnt/efs_wordpress

mkdir -p /home/ec2-user/wordpress
cd /home/ec2-user/wordpress

touch .env
cat <<EOF > .env
WORDPRESS_DB_HOST=${DB_HOST}
WORDPRESS_DB_USER=${DB_USER}
WORDPRESS_DB_PASSWORD=${DB_PASSWORD}
WORDPRESS_DB_NAME=${DB_NAME}
EOF

touch docker-compose.yml
cat <<'EOF' > docker-compose.yml
services:
  wordpress:
    image: wordpress
    restart: always
    ports:
      - "80:80"
    env_file:
      - ./.env
    volumes:
      - /mnt/efs_wordpress:/var/www/html
    networks:
      - minha_network

networks:
  minha_network:
    driver: bridge
EOF

chmod 700 /home/ec2-user/wordpress/.env
chmod 700 /home/ec2-user/wordpress/docker-compose.yml
chown -R ec2-user:ec2-user /home/ec2-user/wordpress

cd /home/ec2-user/wordpress
su ec2-user 

docker-compose up -d 
