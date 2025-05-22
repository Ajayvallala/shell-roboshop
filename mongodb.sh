#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER=$(id -u)
DATE=$(date)

echo "Script execution started at $DATE"

if [ $USER -ne 0 ]
then
 echo "$Y Please switch to root user $N"
 exit 1
else
 echo "$G you are running the script with root $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
     echo "$2 is $R FAILURE $N"
     exit 1
    else
     echo "$2 is $G SUCCESS $N"
}

cp mongo.repo /etc/yum.d.repos/mongodb.repo
VALIDATE $? "Copying repo"

dnf install mongodb-org -y
VALIDATE $? "Installation mongodb"

systemctl enable mongod
VALIDATE $? "enabling mongod"

systemctl start mongod
VALIDATE $? "Starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Updating conf"

systemctl restart mongod
VALIDATE $? "Restarting mongod"





