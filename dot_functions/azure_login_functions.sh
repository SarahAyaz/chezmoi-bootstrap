#!/bin/bash

function welcome() {
    echo "Hello $user"
}

login_deployment_dev_sp() {
    source $HOME/.env_variables
    az account set --subscription "sub-data-dev"
    az login --service-principal -u $DEPLOYMENT_DEV_SP_ID -p $DEPLOYMENT_DEV_SP_SECRET --tenant $AZURE_TENANT_ID
}


login_aad_access_dev_sp() {
    source $HOME/.env_variables
    az login --service-principal -u $AAD_ACCESS_DEV_SP_ID -p $AAD_ACCESS_DEV_SP_SECRET --tenant $AZURE_TENANT_ID --allow-no-subscriptions 
}

login_user_access_prod_sp() {
    source $HOME/.env_variables
    az account set --subscription "sub-data-dev"
    az login --service-principal -u $USER_ACCESS_PROD_SP_ID -p $USER_ACCESS_PROD_SP_SECRET --tenant $AZURE_TENANT_ID
}

create_role_assignment() {
    az role assignment create --assignee-object-id ${assignee} --role ${role} --scope "/subscriptions/514a14f6-e6ae-495b-a5ad-f8a6c27e9815/resourceGroups/rg-data-prod-keyvault/providers/${scope}"
}

login_azuremlupload_prod_sp() {
    source $HOME/.env_variables
    az account set --subscription "sub-data-prod"
    az login --service-principal -u $AZUREMLUPLOAD_PROD_SP_ID -p $AZUREMLUPLOAD_PROD_SP_SECRET --tenant $AZURE_TENANT_ID
}

login_azuremlupload_dev_sp() {
    source $HOME/.env_variables
    az account set --subscription "sub-data-dev"
    az login --service-principal -u $AZUREMLUPLOAD_DEV_SP_ID -p $AZUREMLUPLOAD_DEV_SP_SECRET --tenant $AZURE_TENANT_ID
}