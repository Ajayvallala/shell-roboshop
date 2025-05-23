#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER=$(id -u)
LOG_FOLDER="/var/log/shell_script/"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER$SCRIPT_NAME.log"

echo "Script execution started at $(date)" | tee -a $LOG_FILE

mkdir -p $LOG_FOLDER

if [ $USER -ne 0 ]
then
 echo -e "$Y Please switch to root user $N" | tee -a $LOG_FILE
 exit 1
else
 echo -e "$G you are running the script with root $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
     echo -e "$2 is $R FAILURE $N" | tee -a $LOG_FILE
     exit 1
    else
     echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installation mongodb"

systemctl enable mongod
VALIDATE $? "enabling mongod"

systemctl start mongod
VALIDATE $? "Starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Updating conf"

systemctl restart mongod
VALIDATE $? "Restarting mongod"





