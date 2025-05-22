#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell_script/"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER$SCRIPT_NAME.log"
USER=$(id -u)

mkdir -p $LOG_FOLDER 

echo "Script execution started at $(date)" | tee -a $LOG_FILE

if [ $USER -ne 0 ]
then
 echo -e "$R Please swith to root user $N" | tee -a $LOG_FILE
 exit 1
else
 echo -e " $G you are running with root user $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
     echo -e "$2 is $R Failure $N" | tee -a $LOG_FILE
     exit 1
    else
     echo -e "$2 is $G Success $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable Nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

systemctl enable nodejs &>>$LOG_FILE
VALIDATE $? "Enable Nodejs sevice"

systemctl start nodjs &>>$LOG_FILE
VALIDATE $? "Starting Nodejs"

mkdir -p /app &>>$LOG_FILE

roboshop id &>>$LOG_FILE
if [ $? -ne 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "Roboshop user" roboshop &>>$LOG_FILE
 VALIDATE $? "User Creation"
else
 echo "User already created skipping" | tee -a $LOG_FILE
fi

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Dependencies"

cd /app
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Starting Nodejs"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Catalogue service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon-reload"

systemctl enable catalogue
VALIDATE $? "Enable Catalogue"

systemctl start catalogue
VALIDATE $? "Starting Catalogue"

cp mongo.repo /etc/yum.repos.d/mongodb.repo

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb client"

mongosh --host mongodb.vallalas.store < /app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Loding data into DB"



