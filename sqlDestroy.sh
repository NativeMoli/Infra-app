#!/bin/bash
set -e

# Вкажи свій Project ID та VPC
PROJECT_ID="prodterra"
VPC_NAME="my-vps"
RANGE_NAME="private-service-range"

echo "Видаляємо VPC peering..."
gcloud services vpc-peerings delete \
  --service=servicenetworking.googleapis.com \
  --network="$VPC_NAME" \
  --project="$PROJECT_ID"

echo "Видаляємо глобальну адресу..."
gcloud compute addresses delete "$RANGE_NAME" --global --project="$PROJECT_ID"

echo "Готово!"
