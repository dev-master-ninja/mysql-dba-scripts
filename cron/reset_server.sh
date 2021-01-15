#!/bin/bash
#######
# Reset Server
# Remove mysql-server
#
##############

apt -y remove --purge mysql*
apt -y purge mysql*
apt -y autoremove
apt -y autoclean
apt -y remove dbconfig-mysql
#apt install mysql-server