#!/bin/bash

START_TIME=$(date +%s)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[37m"

LOG_FOLDER="/var/log/shell_script"
LOGFILE_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$LOGFILE_NAME.log"

echo "Script started executing at: $(date)" | tee -a $LOG_FILE

mkdir -p $LOG_FOLDER 

USER=$(id -u)

if [ $USER -ne 0 ]
then
 echo -e "$ $Y Please run with root user $N" | tee -a $LOG_FILE
 exit 1
else
 echo -e "$ $B you are running with root user $N" | tee -a $LOG_FILE
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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Opeaning all the traffic"

sed -i 's/protected-mode yes/protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Disabling protected-mode"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enable redis"

systemctl start redis
VALIDATE $? "Starting redis"

END_TIME=$(date +%s)

TOTAL_TIME=$(($START_TIME - $END_TIME))

echo -e "Script execution completed successfully, $B time taken $TOTAL_TIME seconds" | tee -a $LOG_FILE
