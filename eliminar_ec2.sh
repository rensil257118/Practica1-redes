#!/bin/bash
set -e
source ec2.conf
source red.conf

KEY_NAME="mi-clave-ec2"

echo "Eliminando instancia EC2..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

echo "Eliminando clave SSH..."
aws ec2 delete-key-pair --key-name $KEY_NAME
rm -f ${KEY_NAME}.pem ec2.conf

echo "Instancia EC2 eliminada."
