step1:

vi install-sonarqube.sh


step2:

#!/bin/bash

set -e

echo "======================================"
echo " SonarQube Installation Started"
echo "======================================"

SONAR_VERSION="8.9.10.61524"

SONAR_DB_USER="sonar"
SONAR_DB_PASSWORD="Sonar@123"

POSTGRES_PASSWORD="Postgres@123"


echo "Updating system"

dnf update -y


########################################
# Swap
########################################

if [ ! -f /swapfile ]; then

echo "Creating 2GB swap"

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

echo "/swapfile none swap defaults 0 0" >> /etc/fstab

fi


########################################
# Elasticsearch requirement
########################################

echo "Setting vm.max_map_count"

echo "vm.max_map_count=262144" >> /etc/sysctl.conf

sysctl -w vm.max_map_count=262144



########################################
# Java
########################################

echo "Installing Java"

dnf install -y java-11-amazon-corretto-devel unzip wget tar


JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

echo "JAVA_HOME=$JAVA_HOME"


java -version



########################################
# PostgreSQL
########################################

echo "Installing PostgreSQL"


dnf install -y \
postgresql15 \
postgresql15-server \
postgresql15-contrib


if [ ! -d /var/lib/pgsql/data/base ]; then

echo "Initializing PostgreSQL"

postgresql-setup --initdb

fi


systemctl enable postgresql

systemctl start postgresql || true



########################################
# PostgreSQL passwordless configuration
########################################


echo "Configuring PostgreSQL"


PG_HBA=$(find /var/lib/pgsql -name pg_hba.conf | head -1)


cp $PG_HBA ${PG_HBA}.backup


cat > $PG_HBA <<EOF

local   all             all                                     trust

host    all             all             127.0.0.1/32            trust

host    all             all             ::1/128                 trust

local   replication     all                                     trust

host    replication     all             127.0.0.1/32            trust

host    replication     all             ::1/128                 trust

EOF


systemctl restart postgresql



########################################
# Database creation
########################################


echo "Creating Sonar database"


sudo -u postgres psql <<EOF

ALTER USER postgres WITH PASSWORD '${POSTGRES_PASSWORD}';

DROP DATABASE IF EXISTS sonarqube;

DROP USER IF EXISTS sonar;

CREATE USER sonar WITH PASSWORD '${SONAR_DB_PASSWORD}';

CREATE DATABASE sonarqube OWNER sonar;

GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;

EOF



########################################
# Install SonarQube
########################################


echo "Installing SonarQube"


cd /opt


if [ ! -d /opt/sonarqube ]; then


wget -q https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip


unzip -q sonarqube-${SONAR_VERSION}.zip


mv sonarqube-${SONAR_VERSION} sonarqube


fi



########################################
# Sonar user
########################################


id sonar >/dev/null 2>&1 || useradd sonar


chown -R sonar:sonar /opt/sonarqube



########################################
# Sonar configuration
########################################


cat > /opt/sonarqube/conf/sonar.properties <<EOF


sonar.jdbc.username=${SONAR_DB_USER}

sonar.jdbc.password=${SONAR_DB_PASSWORD}

sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube


sonar.web.host=0.0.0.0

sonar.web.port=9000


EOF



########################################
# Systemd service
########################################


echo "Creating SonarQube service"


cat >/etc/systemd/system/sonarqube.service <<EOF

[Unit]

Description=SonarQube Service

After=network.target postgresql.service


[Service]

Type=forking


User=sonar

Group=sonar


Environment="JAVA_HOME=${JAVA_HOME}"

Environment="PATH=${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"


ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start

ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop


LimitNOFILE=65536

LimitNPROC=4096


Restart=always

RestartSec=10


[Install]

WantedBy=multi-user.target

EOF



########################################
# Start SonarQube
########################################


systemctl daemon-reload

systemctl enable sonarqube

systemctl reset-failed sonarqube

systemctl start sonarqube



echo ""
echo "======================================"
echo " Installation Completed"
echo "======================================"

echo ""

echo "Wait 2-3 minutes"

echo ""

echo "Check:"
echo "ss -tulnp | grep 9000"

echo ""

echo "URL:"
echo "http://YOUR_PUBLIC_IP:9000"

echo ""

echo "Login:"
echo "Username : admin"
echo "Password : admin"

echo ""

echo "PostgreSQL password:"
echo "${POSTGRES_PASSWORD}"

echo ""

echo "Sonar Database password:"
echo "${SONAR_DB_PASSWORD}"

echo "======================================"




step3:

chmod +x install-sonarqube.sh
./install-sonarqube.sh


step4:

sleep 120

ss -tulnp | grep 9000


step5:

http://EC2_PUBLIC_IP:9000
