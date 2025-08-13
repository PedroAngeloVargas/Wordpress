#!/bin/bash
sudo su

apt update -y && apt upgrade -y 

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

apt-get update -y
apt-get install -y ca-certificates curl 
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 

apt-get install -y docker-compose 

usermod -aG docker ubuntu

mkdir /home/ubuntu/monitoring

cd /home/ubuntu/monitoring

touch .env
cat << 'EOF' > .env
GF_SECURITY_ADMIN_USER=${GF_SECURITY_ADMIN_USER}
GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD}
MYSQL_EXPORTER_USER=${MYSQL_EXPORTER_USER}
MYSQL_EXPORTER_PASSWORD=${MYSQL_EXPORTER_PASSWORD}
MYSQL_EXPORTER_HOST=${MYSQL_EXPORTER_HOST}
EOF

chmod 700 .env

touch docker-compose.yml

cat << 'EOF' > docker-compose.yml
services:

  cloudbeaver:
    image: dbeaver/cloudbeaver:latest
    container_name: dbeaver
    ports:
      - "8978:8978"
    environment:
      - CB_SERVER_NAME=CloudBeaver Community
    volumes:
      - cloudbeaver_data:/opt/cloudbeaver/workspace
    networks:
      - minha_network
    restart: always

  mysql-exporter:
    image: quay.io/prometheus/mysqld-exporter
    container_name: mysql-exporter
    restart: always
    command:
     - "--mysqld.username=${MYSQL_EXPORTER_USER}:${MYSQL_EXPORTER_PASSWORD}"
     - "--mysqld.address=${MYSQL_EXPORTER_HOST}"
    networks:
      - minha_network

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    ports:
      - "9090:9090"
    restart: always
    networks: 
      - minha_network

  grafana:
    image: grafana/grafana-oss:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning/:/etc/grafana/provisioning/
    env_file:
      - ./.env
    restart: always
    depends_on:
      - prometheus
    networks: 
      - minha_network

volumes:
  prometheus_data:
  grafana_data:
  cloudbeaver_data:

networks:
  minha_network:
    driver: bridge
EOF

chmod 700 docker-compose.yml

touch prometheus.yml

cat << 'EOF' > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:

  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: 'mysql-database'
    scrape_interval: 15s
    static_configs:

      - targets: ['mysql-exporter:9104']
EOF

chmod 755 prometheus.yml

mkdir -p grafana/provisioning/datasources
touch grafana/provisioning/datasources/prometheus-datasource.yml

cat << 'EOF' > grafana/provisioning/datasources/prometheus-datasource.yml
apiVersion: 1

datasources:
  - name: Prometheus 
    type: prometheus 
    access: proxy   
    url: http://prometheus:9090 
    isDefault: true 
EOF

chown -R ubuntu:ubuntu /home/ubuntu/monitoring
cd /home/ubuntu/monitoring
su ubuntu

docker-compose up -d 
