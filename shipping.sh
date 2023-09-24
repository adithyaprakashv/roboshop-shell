#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install maven -y &>>$LOGFILE
VALIDATE $? "Installing Maven"

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE
VALIDATE $? "Downloading shipping artifact"


unzip /tmp/shipping.zip &>>$LOGFILE
VALIDATE $? "Unzipping Shipping"

cd /app &>>$LOGFILE
VALIDATE $? "Moving into app directory"

mvn clean package &>>$LOGFILE
VALIDATE $? "Maven clean Package"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "Renaming shipping.jar"

cp /home/centos/roboshop-shell/roboshop.conf /systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "Copying Shipping Service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling Shipping"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "Started Shipping"

yum install mysql -y &>>$LOGFILE
VALIDATE $? "Installing Mysql Client"

mysql -h mysql.adithyaprakash.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE
VALIDATE $? "Loading cities and countries info"

systemctl restart shipping &>>$LOGFILE
VALIDATE $? "Restarting Shipping"