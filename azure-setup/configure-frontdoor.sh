#!/bin/bash

# Load configuration
source ./frontdoor.env

echo "Creating resource group..."
az group create --name $RESOURCE_GROUP_GLOBAL --location $LOCATION_PRIMARY --output none

echo "Creating Front Door profile..."
az afd profile create \
  --resource-group $RESOURCE_GROUP_GLOBAL \
  --profile-name $FRONTDOOR_NAME \
  --sku Standard_AzureFrontDoor \
  --output none

echo "Creating Front Door endpoint..."
az afd endpoint create \
  --resource-group $RESOURCE_GROUP_GLOBAL \
  --profile-name $FRONTDOOR_NAME \
  --endpoint-name $ENDPOINT_NAME \
  --enabled-state Enabled \
  --output none

echo "Creating origin group with health probe..."
az afd origin-group create \
  --resource-group $RESOURCE_GROUP_GLOBAL \
  --profile-name $FRONTDOOR_NAME \
  --origin-group-name $ORIGIN_GROUP_NAME \
  --probe-request-type GET \
  --probe-protocol Https \
  --probe-interval-in-seconds 30 \
  --probe-path /api/health \
  --sample-size 4 \
  --successful-samples-required 3 \
  --additional-latency-in-milliseconds 50 \
  --output none

echo "Adding East US origin..."
az afd origin create \
  --resource-group $RESOURCE_GROUP_GLOBAL \
  --profile-name $FRONTDOOR_NAME \
  --origin-group-name $ORIGIN_GROUP_NAME \
  --origin-name ingress-eastus \
  --host-name $INGRESS_DOMAIN_EAST \
  --origin-host-header $INGRESS_DOMAIN_EAST \
  --priority 1 \
  --weight 1000 \
  --enabled-state Enabled \
  --http-port 80 \
  --https-port 443 \
  --output none

echo "Adding West US origin..."
az afd origin create \
  --resource-group $RESOURCE_GROUP_GLOBAL \
  --profile-name $FRONTDOOR_NAME \
  --origin-group-name $ORIGIN_GROUP_NAME \
  --origin-name ingress-westus \
  --host-name $INGRESS_DOMAIN_WEST \
  --origin-host-header $INGRESS_DOMAIN_WEST \
  --priority 2 \
  --weight 1000 \
  --enabled-state Enabled \
  --http-port 80 \
  --https-port 443 \
  --output none

echo "Creating route for API traffic..."
az afd route create \
  --resource-group $RESOURCE_GROUP_GLOBAL \
  --profile-name $FRONTDOOR_NAME \
  --endpoint-name $ENDPOINT_NAME \
  --route-name $ROUTE_NAME \
  --origin-group $ORIGIN_GROUP_NAME \
  --supported-protocols Http Https \
  --patterns-to-match "/api/*" \
  --forwarding-protocol MatchRequest \
  --https-redirect Enabled \
  --origin-path "/" \
  --caching-behavior Disabled \
  --link-to-default-domain Enabled \
  --output none

echo "Azure Front Door setup complete. Your global API is live at:"
az afd endpoint show \
  --resource-group $RESOURCE_GROUP_GLOBAL \
  --profile-name $FRONTDOOR_NAME \
  --endpoint-name $ENDPOINT_NAME \
  --query "hostName" \
  --output tsv
