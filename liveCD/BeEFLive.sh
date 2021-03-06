#!/bin/bash
#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'home/beef/doc/COPYING' for copying permission
#

   
#
# This is the auto startup script for the BeEF Live CD. 
# IT SHOULD ONLY BE RUN ON THE LIVE CD
# Download LiveCD here: http://beefproject.com/BeEFLive1.2.iso
# MD5 (BeEFLive1.2.iso) = 1bfba0942a3270ee977ceaeae5a6efd2
#
# This script contains a few fixes to make BeEF play nicely with the way  
# remastersys creates the live cd distributable as well as generating host keys 
# to enable SSH etc. The script also make it easy for the user to update/start 
# the BeEF server
#
clear
echo "======================================"
echo "          BeEF Live CD   "
echo "======================================"
echo ""
echo "Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net"
echo "Browser Exploitation Framework (BeEF) - http://beefproject.com"
echo "See the file 'home/beef/doc/COPYING' for copying permission"
echo ""

echo "Welcome to the BeEF Live CD" 
echo "" 
echo ""

#
# Check for SSH Host Keys - if they do not exist ask user if they should be 
# created (remastersys has a habit of deleting them during Live CD Creation)
#
f1="/etc/ssh/ssh_host_rsa_key"
if [ -f $f1 ]
then
	echo ""
else 
	echo -n "Would you like to enable ssh (y/N)? "
	read var
	
	if [ $var = "y" ] ; then
		 sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
		 sudo ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
		 echo ""
		 echo "Please provide a password for ssh user: beef"
		 sudo passwd beef
		 echo "ssh enabled"
	fi
fi
echo ""

#
# Prompt the user if they would like to update BeEF and 
# other components installed (such as sqlmap and msf)
#
echo -n "Check and install updates for BeEF (y/N)? "
read var

if [ $var = "y" ] ; then
	 cd /opt/beef
	 git stash
	 git pull
fi
echo ""

echo -n "Check and install updates for msf and sqlmap (y/N)? "
read var

if [ $var = "y" ] ; then
 	 cd /opt/sqlmap
 	 git stash
	 git pull
	 cd /opt/metasploit-framework
	 git stash
	 git pull
fi
 
 
#
# Create a shortcut in the user's home folder to BeEF, msf and sqlmap
# (if they do not yet exist)
#
f1="beef"
if [ -f $f1 ] ; then
	echo ""
else
	ln -s /opt/beef/ beef
	ln -s /opt/metasploit-framework/ msf
	ln -s /opt/sqlmap/ sqlmap
fi

#
# Prompt the user if they would like start BeEF
#
echo -n "Start BeEF (y/N)? "
read var

#
# function to allow beef to run in the background
#
run_beef() {
    echo ""
	echo "Starting BeEF..";
	
	cd /opt/beef/
	ruby beef -x
}

if [ $var = "y" ] ; then
	run_beef &
	sleep 5
fi

#
# Prompt the user if they would like start sqlmap using beef as proxy
#

echo ""
echo -n "Start sqlMAP with BeEF Proxy? (y/N)? "
read var

if [ $var = "y" ] ; then
	echo ""
	echo "sqlMAP can now be run using the --proxy command set to the BeEF Proxy: http://127.0.0.1:6789 starting the wizard to demo with:"
	echo "python /opt/sqlmap/sqlmap.py --proxy http://127.0.0.1:6789 --wizard"
	sleep 5
	python /opt/sqlmap/sqlmap.py --proxy http://127.0.0.1:6789 --wizard
fi




