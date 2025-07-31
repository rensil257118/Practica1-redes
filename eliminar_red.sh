#!/bin/bash
set -e
source red.conf

echo "Eliminando recursos de red..."

aws ec2 delete-security-group --group-id $SG_ID
aws ec2 disassociate-route-table --association-id $(aws ec2 describe-route-tables --route-table-ids $RT_ID \
  --query 'RouteTables[0].Associations[0].RouteTableAssociationId' --output text)

aws ec2 delete-route-table --route-table-id $RT_ID
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
aws ec2 delete-subnet --subnet-id $SUBNET_ID
aws ec2 delete-vpc --vpc-id $VPC_ID

rm -f red.conf
echo "Red eliminada."
