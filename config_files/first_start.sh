#!/bin/ash
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
rc-update add sshd 
rc-service sshd start
echo "****"
echo "'"
echo "Don't forget to set root-ssh password !!!"
echo "*"
echo "****"
echo "*"
echo "first_start.sh completed !"
echo "*"
echo "****"
rc-update del auto_init