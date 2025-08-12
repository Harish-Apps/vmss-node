#!/bin/bash
# Azure CLI commands to provision resources for the blog

az group create --name functionRG --location centralindia

az storage account create --name dhaappsaznefunc --location centralindia --resource-group functionRG --sku Standard_LRS

az functionapp create --resource-group functionRG --consumption-plan-location centralindia --runtime python --runtime-version 3.10 --functions-version 4 --name dhaappsaznewf --os-type linux --storage-account dhaappsaznefunc
