#!/bin/bash
set -e
source red.conf

KEY_NAME="mi-clave-ec2"

echo "Creando par de llaves..."
aws ec2 create-key-pair --key-name $KEY_NAME \
  --query 'KeyMaterial' --output text > ${KEY_NAME}.pem

chmod 400 ${KEY_NAME}.pem

AMI_ID="ami-0c02fb55956c7d316"
INSTANCE_TYPE="t2.micro"

echo "Lanzando instancia EC2..."
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID \
  --count 1 --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --region $REGION \
  --query 'Instances[0].InstanceId' --output text)

aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=mi-ec2

echo "Esperando a que la instancia esté en estado 'running'..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

IP_PUBLICA=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "Instancia creada: $INSTANCE_ID"
echo "IP Pública: $IP_PUBLICA"

echo "INSTANCE_ID=$INSTANCE_ID" > ec2.conf
