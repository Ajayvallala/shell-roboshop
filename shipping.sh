#!/bin/bash

START_TIME=$(date +%s)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "MVN Installation"

mkdir -p /app &>>$LOG_FILE

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "Roboshop user" roboshop &>>$LOG_FILE
 VALIDATE $? "User Creation"
else
 echo "User already created skipping" | tee -a $LOG_FILE
fi

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading Dependencies"

rm -rf /app/*
cd /app
unzip /tmp/shipping.zip &>>$LOG_FILE

mvn clean package &>>$LOG_FILE
VALIDATE $? "Packaging source code"

mv target/shipping-1.0.jar.original shipping.jar 
VALIDATE $? "Moving jar file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "shipping service creation"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon-reload"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enable shipping service"

systemctl start shipping
VALIDATE $? "Starting shipping service"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing Mysql client"

mysql -h mysql.vallalas.store -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE

mysql -h mysql.vallalas.store -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE

mysql -h mysql.vallalas.store -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
VALIDATE $? "Data loaded in DB"

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Shipping service"

END_TIME=$(date +%s)

TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "Script execution completed successfully, $B time taken $TOTAL_TIME seconds" | tee -a $LOG_FILE

