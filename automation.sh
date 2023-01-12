#!/bin/bash
#variables
name="dhiraj"
s3_bucket="dhirajupgrad"
#Perform an update of the package details and the package list at the start of the script
sudo apt update -y
echo -e "\033[0;32m sucess"
# Install the apache2 package if it is not already installed. (The dpkg and apt commands are used to check the installation of the packages.)
if [[ apache2 != $(apt --get-selections apache2 | awk '{print $1}') ]];
then
   #statement
   apt install apache2 -y
   echo -e "\033[0;32m sucess"
fi
# checking apache2 is running
running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running = ${running} ]]
then
    #statements
    systemctl start apache2
    echo -e "\033[0;32m sucess"
fi
# Ensures apache2 Service is enabled
enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]]; then
    #statements
    systemctl enable apache2
    echo -e "\033[0;32m sucess"
fi
# creating filename
timestamp=$(date '+%d%m%Y-%H%M%S')

# Create tar archive of Lache2 access and error logs
cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log
# copy logs to s3 bucket
if [[ -f/tmp/${name}-httpd-logs-${timestamp}.tar ]]; then
    #statements
    aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
    echo -e "\033[0;32m sucess"
fi

docroot="/var/www/html"
# Check if inventory file exists
if [[ ! -f ${docroot}/inventory.html ]]
then
    # comments
    echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${docroot}/inventory.html
    echo -e "\033[0;32m sucess"
fi
# Inserting Logs into the file
if [[ -f ${docroot}/inventory.html ]]
then
    #comments
    size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
    echo -e 'httpd-logs\t-\t${timestamp}\t-\ttar\t-\t$(size}' >> ${docroot}/inventory.html
    echo -e "\033[0;32m sucess"
fi

# Create a cron job that runs service every minutes/day

if [[ ! -f /etc/cron.d/automation ]]
then
    #comments
    echo "* * * root /root/automation.sh" >> /etc/cron.d/automation
fi

