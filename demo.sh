#!/usr/bin/env bash

#####################
# SETUP
#####################

PROJECT=$(gcloud config get-value core/project)
#REGION=$(gcloud config get-value compute/region)
REGION=us-west1
CLUSTER_NAME=regional-sandbox-cluster

echo "Creating a cluster called ${CLUSTER_NAME}..."
gcloud container clusters create $CLUSTER_NAME \
  --enable-ip-alias --region $REGION --project $PROJECT \
  --machine-type=n1-standard-4 --num-nodes=6

echo "Getting kubectl creds for your cluster..."
gcloud container clusters get-credentials $CLUSTER_NAME \
  --region $REGION --project $PROJECT
kubectl create namespace spinnaker
kubectl create namespace monitoring
kubectl create namespace istio-system

#####################
# INSTALL APPS
#####################

echo "Installing Spinnaker with helm..."
helm install spinnaker stable/spinnaker \
  --namespace spinnaker \
  --values spinnaker-values.yaml

echo "Installing Prometheus Operator with helm..."
helm install prometheus-operator stable/prometheus-operator \
  --namespace monitoring \
  --values prometheus-operator-values.yaml

#########
# ISTIO
#########
echo "Installing Istio-init with helm..."
curl -L https://git.io/getLatestIstio | sh -
cd istio-1.4.2
helm install istio-init install/kubernetes/helm/istio-init --namespace istio-system

echo "Waiting for istio jobs to complete..."
kubectl -n istio-system wait --for=condition=complete job --all

echo "Installing Istio with helm..."
helm install istio install/kubernetes/helm/istio --namespace istio-system \
  --values ../istio-values.yaml

echo "waiting a minute before installing sample application..."
sleep 60

# echo "installing sample application BookInfo..."
# kubectl label namespace default istio-injection=enabled
# kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml


cd ..

#######################
# Prometheus Operator
#######################
echo "Installing Istio Telemetry's Prometheus Operator service monitor..."
curl -sL -o istio-installer.zip https://github.com/istio/installer/archive/master.zip
unzip -oqq istio-installer.zip
helm install istio-prometheus-operator \
  ./installer-master/istio-telemetry/prometheus-operator \
  --namespace monitoring --set global.telemetryNamespace=istio-system \
  --set prometheusOperator.createPrometheusResource=false
