#!/bin/bash

# Variables
RESOURCE_GROUP="teleios-dupe-rg"
AKS_NAME="rideshare-aks-cluster"
ACR_NAME="teleiosdupeacr01"
LOCATION="West US"
NODE_SIZE="Standard_B2ps_v2"  # Or use Standard_D2pds_v5
MIN_NODES=2
MAX_NODES=6

# Create AKS cluster with ACR integration and monitoring enabled
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --location "$LOCATION" \
  --node-vm-size $NODE_SIZE \
  --enable-cluster-autoscaler \
  --min-count $MIN_NODES \
  --max-count $MAX_NODES \
  --attach-acr $ACR_NAME \
  --enable-addons monitoring \
  --network-plugin azure \
  --generate-ssh-keys

# Get credentials to access the cluster via kubectl
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

