#!/bin/bash

AMIID="ami-09c813fb71547fc4f"
SG_ID="sg-007aa1e4ce81005d7"
INSTANCE_TYPE="t2.micro"
SUBNET_ID="subnet-07d9ef0ea659b9697"
INSTANCES_LIST=("mongodb" "catalogue" "frontend")
ZONEID="Z0638351DE255MIV6AWU"
DOMAIN_NAME="vallalas.store"

for instance in ${INSTANCES_LIST[@]}
do
   INSTANCE_ID=$(aws ec2 run-instances \
   --image-id $AMIID \           # Replace with your AMI ID
   --instance-type $INSTANCE_TYPE \                   # Replace with desired instance type
   --security-group-ids $SG_ID \  # Replace with your security group ID
   --subnet-id $SUBNET_ID \                # Optional: specify subnet ID
   --associate-public-ip-address \
   --query 'Instances[0].InstanceId' \
   --output text)
  
  if [ $instance != "frontend" ]
  then 
    IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)
  else
   IP=$(aws ec2 describe-instances \
   --instance-ids $INSTANCE_ID \
   --query 'Reservations[0].Instances[0].PublicIpAddress' \
   --output text)
  fi

  aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONEID \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$instance.$DOMAIN_NAME",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [{"Value": "$IP"}]
      }
    }]
  }'

 echo "$instance ip address is $IP"

done