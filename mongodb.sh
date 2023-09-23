#! /bin/bash

# logs Validation script
DATE=$(date +%F)
LOGSDIR=/tmp
#LOGSDIR=/home/centos/shellscript-logs
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log

#color codes
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

#user access
USERID=$(id -u)

if [ $USERID -ne 0 ]
then 
    echo -e "$R ERROR :: Please do install this with a root user $N"
    exit 1
#else
#   echo "INFO :: You are a root user"    
fi

#validate through function VALIDATE
VALIDATE()
{    
    if [ $1 -ne 0 ]
    then 
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

#copy mongo.repo file with vim path as in roboshop documentation
#give validations for each ie copied & pasted from mongodb.md in roboshop documentation

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "copied mongodb repo into yum.repos.d"

yum install mongodb-org -y &>>$LOGFILE

VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOGFILE

VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOGFILE

VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$LOGFILE

VALIDATE $? "edited Mongo Conf"

systemctl restart mongod &>>$LOGFILE

VALIDATE $? "Restarting MongoDB"