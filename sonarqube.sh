======
TAKE SonarQube.sh to install ======

Expand window to show video
SETUP: Launch another EC2 instance - Amazon linux 2 - t2.medium is must , it will not run on micro
============ script

===

#! /bin/bash
#Launch an instance t2.medium, port 9000

vi sonar.sh 
paste below commands and save

--start--

cd /opt/
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
unzip sonarqube-8.9.6.50800.zip
sudo dnf install java-21-amazon-corretto -y
useradd sonar
chown sonar:sonar sonarqube-8.9.6.50800 -R
chmod 777 sonarqube-8.9.6.50800 -R
su - sonar


--end--

sh sonar.sh


# use the below command manually after installation
#sh /opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh start
#echo "user=admin & password=admin"
