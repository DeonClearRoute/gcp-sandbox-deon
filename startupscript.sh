#! /bin/bash

#User passwords
PASSWORD_INST="db2inst123"
PASSWORD_FENC="db2fenc123"
#DB2 Installer File Location
DB2_INSTALLER_LOCATION=https://gcp-public-download.s3.eu-west-1.amazonaws.com/v11.5.9_linuxx64_server_dec.tar.gz


#Run download non verbose (-q)
wget -q -P /tmp $DB2_INSTALLER_LOCATION
tar -xvzf /tmp/v11.5.9_linuxx64_server_dec.tar.gz -C /tmp

sudo apt update

sudo apt -y install binutils

sudo apt -y install libnuma1

sudo dpkg --add-architecture i386

sudo apt update

sudo apt -y install libpam0g:i386

sudo apt -y install libaio1:i386

sudo apt -y install libstdc++6:i386

#https://www.ibm.com/docs/en/db2/11.5?topic=commands-db2-install-install-db2-database-product
sudo /tmp/server_dec/db2_install -b /opt/ibm/db2/V11.5 -p SERVER -n -y
# pass default path after /db2_install >>>  -b /opt/ibm/db2/V11.5 (DONE)

#instance group
sudo groupadd db2iadm1

#instance fenced user
sudo groupadd db2fadm1

#instance server
sudo groupadd dasadm1

#Create users
sudo useradd -m -g db2iadm1 -d /home/db2inst1 -s /bin/bash db2inst1

sudo useradd -m -g db2fadm1 -d /home/db2fenc1 -s /bin/bash db2fenc1

#Add password to users (openssl encrpyted only)
usermod --password $(echo $PASSWORD_INST | openssl passwd -1 -stdin) db2inst1
usermod --password $(echo $PASSWORD_FENC | openssl passwd -1 -stdin) db2fenc1


#Create db instance with users db2inst1
sudo /opt/ibm/db2/V11.5/instance/db2icrt -u db2fenc1 db2inst1

# #Start DB2!
sudo su - db2inst1 -c "db2start"
# #Create db
sudo su - db2inst1 -c "db2 create database poc_db"

#Execute DB2 commands with db2inst1 user session
sudo su - db2inst1 <<!
db2 connect to poc_db
db2 "create table hitsquad (id INT PRIMARY KEY NOT NULL, name varchar(50))"
db2 "insert into hitsquad (id, name) values (0, 'Glyn')"
db2 "insert into hitsquad (id, name) values (1, 'Lucas')"
db2 "insert into hitsquad (id, name) values (2, 'Deon')"
!

#Dump output to log file in root directory
sudo journalctl -u google-startup-scripts.service > ~/startup-script.log

# TODO: Manual CLI solution has the issue: user does not stay loggedin after 'su' runs, therefore the above has been implented.
# #Connect to db & create a table
# sudo su - db2inst1

# db2 connect to poc_db
# db2 "create table hitsquad (id INT PRIMARY KEY NOT NULL, name varchar(50))"
# #Add sample data
# db2 "insert into hitsquad (id, name) values (0, 'Glyn')"
# db2 "insert into hitsquad (id, name) values (1, 'Lucas')"
# db2 "insert into hitsquad (id, name) values (2, 'Deon')"