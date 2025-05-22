#!/bin/bash

AMIID="ami-09c813fb71547fc4f"
SG_ID="sg-007aa1e4ce81005d7"
INSTANCE_TYPE="t2.micro"
INSTANCES=("mongodb" "catalogue" "Frontend")
SUBNET_ID="subnet-07d9ef0ea659b9697"

for instance in ${INSTANCES[@]}
do 
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMIID \
    --instance-type $INSTANCE_TYPE \
    --security-group-ids $SG_GROUP \
    --subnet-id $SUBNET_ID \
    --associate-public-ip-address \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)

    if [ "${instance,,}" != "frontend" ]
    then 
     IP=$(aws ec2 describe-instances \
       --instance-ids $INSTANCE_ID \
       --query "Reservations[0].Instances[0].PrivateIpAddress" \
       --output text)
    else
     IP=$(aws ec2 describe-instances \
       --instance-ids $INSTANCE_ID \
       --query "Reservations[0].Instances[0].PublicIpAddress" \
       --output text)
    fi
    echo "$instance ip address is $IP"
done