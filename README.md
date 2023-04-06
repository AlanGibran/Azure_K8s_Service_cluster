# Prerequisites
Use the Bash environment in Azure Cloud Shell.
This app requires version 2.0.64 or later of the Azure CLI. If using Azure Cloud Shell, the latest version is already installed.
The identity we are using to create the cluster has the appropriate minimum permissions. 
Verify Microsoft.OperationsManagement and Microsoft.OperationalInsights providers are registered on the subscription. These are Azure resource providers required to support Container insights.

I deployed this app using the Bash environment in Azure Cloud Shell, and I'd previously created the AKS cluster (and set a proper pasword).
Full documentation: https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli
