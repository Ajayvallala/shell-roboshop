#!/bin/bash

START_TIME=$(date +%s)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

LOG_FOLDER="/var/log/shell_script/"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER$SCRIPT_NAME.log"
USER=$(id -u)
SCRIPT_DIR="$PWD"

mkdir -p $LOG_FOLDER 

echo "Script execution started at $(date)" | tee -a $LOG_FILE

if [ $USER -ne 0 ]
then
 echo -e "$R Please swith to root user $N" | tee -a $LOG_FILE
 exit 1
else
 echo -e "$G You are running with root user $N" | tee -a $LOG_FILE
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

cp $PWD/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Creating Rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing Rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enable Rabbitmq"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting Rabbitmq"

rabbitmqctl list_users | grep roboshop &>>$LOG_FILE

if [ $? -ne 0 ]
then
  rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
  VALIDATE $? "Creating Rabbitmq user"

  rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
  VALIDATE $? "Setting Permissions to Rabbitmq user"
else
 echo -e "$B User already created skipping$N"
fi

END_TIME=$(date +%s)

TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "Script execution completed successfully, $B time taken $TOTAL_TIME seconds" | tee -a $LOG_FILE
