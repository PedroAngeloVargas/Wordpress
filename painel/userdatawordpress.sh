#!/bin/bash
sudo su

PARAM_DB_HOST="/seu/caminho/db_host"
PARAM_DB_USER="/seu/caminho/db_user"
PARAM_DB_PASSWORD="/seu/caminho/db_password"
PARAM_DB_NAME="/seu/caminho/db_name"
PARAM_EFS_ID="/seu/caminho/efs_id"

yum update -y

yum install -y docker nfs-utils jq
amazon-linux-extras enable docker

EFS_ID=$(aws ssm get-parameter --name "$PARAM_EFS_ID" --region us-east-1 --query "Parameter.Value" --output text)
DB_HOST=$(aws ssm get-parameter --name "$PARAM_DB_HOST" --region us-east-1 --query "Parameter.Value" --output text)
DB_NAME=$(aws ssm get-parameter --name "$PARAM_DB_NAME" --region us-east-1 --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "$PARAM_DB_PASSWORD" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "$PARAM_DB_USER" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)

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
chown -R root:root /home/ec2-user/wordpress/.env
chown -R ec2-user:ec2-user /home/ec2-user/wordpress

cd /home/ec2-user/wordpress
su ec2-user 

docker-compose up -d 
