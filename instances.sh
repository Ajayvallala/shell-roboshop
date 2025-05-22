#!/bin/bash

AMIID="ami-09c813fb71547fc4f"
SG_GROUP="sg-007aa1e4ce81005d7"
INSTANCE_TYPE="t2.micro"
INSTANCES=("mongodb" "catalogur" "frontend")


for instances ${INSTANCES[@]}
do 
    aws ec2 run-instances \
    --image-id $AMIID \
    --instance-type $INSTANCE_TYPE \
    --security-group-ids $SG_GROUP \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instances}]"
done