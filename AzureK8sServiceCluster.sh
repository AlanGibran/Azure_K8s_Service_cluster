#!/bin/bash

#Deploy an Azure Kubernetes Service cluster using the Azure CLI
#There are some prerequisites like verifying the Microsoft.OperationsManagement and Microsoft.OperationalInsights providers are registered on the subscription

#Verify Microsoft.OperationsManagement and Microsoft.OperationalInsights providers are registered on the subscription. 
az provider show -n Microsoft.OperationsManagement -o table
az provider show -n Microsoft.OperationalInsights -o table

#Create a resource group using the az group create command.
az group create --name myResourceGroup --location eastus

#Create AKS cluster
az aks create -g myResourceGroup -n myAKSCluster --enable-managed-identity --node-count 1 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys

#Configure kubectl to connect to the Kubernetes cluster
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

#Verify the connection
kubectl get nodes

#Deploy the application
touch azure-vote.yaml
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
        env:
        - name: ALLOW_EMPTY_PASSWORD
          value: "yes"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front" > azure-vote.yaml 

#Deploy the application using the kubectl apply command
kubectl apply -f azure-vote.yaml

#test the application
kubectl get service azure-vote-front --watch

#we open the external IP on the browser to test the application

