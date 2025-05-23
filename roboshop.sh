#!/bin/bash

AMIID="ami-09c813fb71547fc4f"
SG_ID="sg-007aa1e4ce81005d7"
INSTANCE_TYPE="t2.micro"
SUBNET_ID="subnet-07d9ef0ea659b9697"
#INSTANCES_LIST=("mongodb")
ZONEID="Z0638351DE255MIV6AWU"
DOMAIN_NAME="vallalas.store"

#for instance in ${INSTANCES_LIST[@]}

for instance in $@    #collecting server details at runtime as arguments
do
   INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMIID \
    --instance-type $INSTANCE_TYPE \
    --security-group-ids $SG_ID \
    --subnet-id $SUBNET_ID \
    --associate-public-ip-address \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text) 
    
 #if instance in frontend collect public ip if not collect private ip

  if [ $instance != "frontend" ]
  then 
    IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)
    RECORD_NAME="$instance.$DOMAIN_NAME"
  else
   IP=$(aws ec2 describe-instances \
   --instance-ids $INSTANCE_ID \
   --query 'Reservations[0].Instances[0].PublicIpAddress' \
   --output text)
   RECORD_NAME="$DOMAIN_NAME"
  fi

#Create or update route53 records with ip address

  aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONEID" \
  --change-batch "{
    \"Comment\": \"UPSERT A record for ${instance}.${DOMAIN_NAME}\",
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"${RECORD_NAME}\",
        \"Type\": \"A\",
        \"TTL\": 1,
        \"ResourceRecords\": [{
          \"Value\": \"${IP}\"
        }]
      }
    }]
  }"

 echo "$instance ip address is $IP"

done