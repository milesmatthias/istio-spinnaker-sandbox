#!/usr/bin/env bash

#####################
# SETUP
#####################

PROJECT=$(gcloud config get-value core/project)
ZONE=$(gcloud config get-value compute/zone)
CLUSTER_NAME=sandbox-cluster

echo "Creating a cluster called ${CLUSTER_NAME}..."
gcloud container clusters create $CLUSTER_NAME \
  --enable-ip-alias --zone $ZONE --project $PROJECT \
  --machine-type=n1-standard-4

echo "Getting kubectl creds for your cluster..."
gcloud container clusters get-credentials $CLUSTER_NAME \
  --zone $ZONE --project $PROJEC
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


echo "Installing Istio-init with helm..."
curl -L https://git.io/getLatestIstio | sh -
cd istio-1.4.0
helm install istio-init install/kubernetes/helm/istio-init --namespace istio-system

echo "Waiting for istio jobs to complete..."
kubectl -n istio-system wait --for=condition=complete job --all

echo "Installing Istio with helm..."
helm install istio install/kubernetes/helm/istio --namespace istio-system

echo "waiting a minute before installing sample application..."
sleep 60

echo "installing sample application BookInfo..."
kubectl label namespace default istio-injection=enabled
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml


cd ..

echo "Installing Istio Telemetry's Prometheus Operator..."
curl -sL -o istio-installer.zip https://github.com/istio/installer/archive/master.zip
unzip -oqq istio-installer.zip
helm install prometheus-operator \
	./installer-master/istio-telemetry/prometheus-operator \
	--namespace monitoring --set global.telemetryNamespace=istio-system

echo "Installing Spinnaker's Prometheus Operator service monitor..."
kubectl apply -n monitoring -f spinnaker-service-monitor.yaml
