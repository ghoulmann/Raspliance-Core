#!/bin/sh
printf "Are you sure you want to uninstall Webmin? (y/n) : "
read answer
printf "\n"
if [ "$answer" = "y" ]; then
	/etc/webmin/stop
	echo "Running uninstall scripts .."
	(cd "/usr/share/webmin/" ; WEBMIN_CONFIG=/etc/webmin WEBMIN_VAR=/var/webmin LANG= "/usr/share/webmin//run-uninstalls.pl")
	echo "Deleting /usr/share/webmin/ .."
	rm -rf "/usr/share/webmin/"
	echo "Deleting /etc/webmin .."
	rm -rf "/etc/webmin"
	echo "Done!"
fi
