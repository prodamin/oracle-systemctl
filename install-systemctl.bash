#!/usr/bin/bash
# This script configures systemd startup service for Oracle Databases and Listener
if [ `whoami` != "root" ]; then
echo "root login required!"
exit
fi
if [ `uname -s` != "Linux" ]; then
echo "This is not Linux!"
exit
fi
if [ `ps -e|grep " 1 ?"|cut -d " " -f15` != "systemd" ]; then
echo "Systemd is not present, use Init scripts instead!"
exit
fi
echo "List of existing Oracle Homes:"
echo "——————————"
cat `cat /etc/oraInst.loc|grep inventory_loc|cut -d '=' -f2`/ContentsXML/inventory.xml|grep "HOME NAME"|cut -d '"' -f 4
echo
echo "Enter ORACLE_HOME of Oracle Listener [$ORACLE_HOME]:"
read NEWHOME
case "$NEWHOME" in
"") ORAHOME="$ORACLE_HOME" ;;
*) ORAHOME="$NEWHOME" ;;
esac
if [ -z $ORAHOME ]; then
echo "Error: Missing value!"
exit
fi
if [ -f $ORAHOME/bin/lsnrctl ]; then
echo '# /etc/systemd/system/oracle-rdbms.service
# Invoking Oracle scripts to start/shutdown Instances defined in /etc/oratab
# and starts Listener
[Unit]
Description=Oracle Database(s) and Listener
Requires=network.target
[Service]
Type=forking
Restart=no
ExecStart='$ORAHOME'/bin/dbstart '$ORAHOME'
ExecStop='$ORAHOME'/bin/dbshut '$ORAHOME'
User=oracle
[Install]
WantedBy=multi-user.target' > /etc/systemd/system/oracle-rdbms.service
systemctl daemon-reload
systemctl enable oracle-rdbms
echo "Done! Service oracle-ordbms has been configured and will be started during next boot."
echo "If you want to start service now, execute: systemctl start oracle-rdbms"
else
echo "Error: No Listener script under specified ORACLE_HOME: $ORAHOME"
exit
fi
