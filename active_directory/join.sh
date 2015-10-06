#!/bin/bash

# Did you run the script as root?
if [ "$(whoami)" != 'root' ]; then
  echo "You must run this script as the root user."
  exit 1;
fi

while true
do
  if [ "$(hostname)" = "localhost.localdomain" ]; then
   echo "You must change the hostname before running this script."
   while true
   do
    read -p "Hostname: " hostname1
    echo
    read -p "Hostname (again): " hostname2
    echo
    [ "$hostname1" = "$hostname2" ] && break
    echo "Hostnames don't match. Please try again."
  done
else
  echo "Current Hostname:" $(hostname)
  read -p "Is the above hostname acceptable? (y/n): " changename
  while [ $changename != "y" ] && [ $changename != "Y" ]
  do
    read -p "New Hostname: " hostname1
    echo
    read -p "New Hostname (again): " hostname2
    echo
    if [[ "$hostname1" == "$hostname2" && "$hostname1" != "" ]]; then
      break
    fi
    echo "Hostnames don't match. Hostname also can't be blank. Please try again."
  done
fi
read -p "Domain: " domain
read -p "Domain Controller FQDN: " dc
read -p "Domain security group for sudo permissions? " adgroup
read -p "Domain Username: " user
read -p "Password: " -s password
echo
echo
echo "Domain:" $domain
echo "Domain Controller FQDN:" $dc
echo "Domain security group for sudo: " $adgroup
echo "User:" $user
read -p "Are you sure the above is correct? (y/n): " answer
if [ $answer = "y" ] || [ $answer = "Y" ]; then
  break
fi
done

# Set hostname
hostnamectl set-hostname $hostname1

# Ensuring hostname has been changed before installing packages and proceeding
if [ "$(hostname)" = "localhost.localdomain" ]; then
  echo "Unacceptable Hostname for the system."
  exit 1;
fi

echo
echo "Beginning Installation"
echo

# Installing required packages
yum -y install realmd sssd ntpdate ntp

# Enabling ntpd daemon
systemctl enable ntpd.service

# Setting time of server to match Domain Controller
ntpdate $dc

# Starting ntpd daemon
systemctl start ntpd.service

# Joining Active Directory Domain
echo $password | realm join --user=$user $domain

# Configuring SSSD
sed -i "s/use_fully_qualified_names/#use_fully_qualified_names/g" /etc/sssd/sssd.conf
realm permit --groups linuxitadmins linuxusers
echo %$adgroup'  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Ask user to reboot the system
read -p "Would you like to reboot the system? (y/n): " reboot
if [ $reboot = "y" ] || [ $reboot = "Y" ]; then
  systemctl reboot
fi
