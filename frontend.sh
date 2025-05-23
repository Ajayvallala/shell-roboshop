#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

LOG_FOLDER="/var/log/shell_script"
LOGFILE_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOGFILE_NAME.log"
  
mkdir -p $LOG_FOLDER 

if [ $? -ne 0 ]
then
 echo -e "$R Permission denied to create log folder switch to root $N"
 exit 1
fi

USER=$(id -u)
SCRIPT_DIR="$PWD"

if [ $USER -ne 0 ]
then
 echo -e "$Y Please switch to root user $N" | tee -a $LOG_FILE
 exit 1
else
 echo -e "$Y You are running the script with root $N" | tee -a $LOG_FILE
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


dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling nginx:1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing default html content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading source code"

unzip /tmp/frontend.zip /usr/share/nginx/html/

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Copying nginx.conf file"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting nginx"




