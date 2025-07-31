#!/bin/bash
set -e

REGION="us-east-1"
VPC_NAME="mi-vpc"
SUBNET_NAME="mi-subnet"
IGW_NAME="mi-igw"
ROUTE_TABLE_NAME="mi-rt"
SG_NAME="mi-sg"

echo "Creando VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
  --region $REGION --query 'Vpc.VpcId' --output text)

aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME

echo "Creando Subnet pública..."
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 --availability-zone ${REGION}a \
  --query 'Subnet.SubnetId' --output text)

aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value=$SUBNET_NAME

echo "Creando Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=$IGW_NAME

echo "Creando tabla de rutas..."
RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' --output text)

aws ec2 create-route --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $RT_ID
aws ec2 create-tags --resources $RT_ID --tags Key=Name,Value=$ROUTE_TABLE_NAME

echo "Haciendo la subnet pública..."
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch

echo "Creando Security Group..."
SG_ID=$(aws ec2 create-security-group --group-name $SG_NAME \
  --description "Acceso SSH y HTTP" --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 22 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

echo "Guardando variables en red.conf..."
cat <<EOF > red.conf
VPC_ID=$VPC_ID
SUBNET_ID=$SUBNET_ID
IGW_ID=$IGW_ID
RT_ID=$RT_ID
SG_ID=$SG_ID
REGION=$REGION
EOF

echo "Infraestructura de red creada con éxito."
