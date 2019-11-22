#!/usr/bin/env bash

PROM_POD=$(kubectl get pods --namespace monitoring -l "app=prometheus" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace monitoring $PROM_POD 9090 > /dev/null 2>&1 & echo $! > prom.pid

GRAFANA_POD=$(kubectl get pods --namespace monitoring -l "app=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace monitoring $GRAFANA_POD 3000 > /dev/null 2>&1 & echo $! > grafana.pid 

DECK_POD=$(kubectl get pods --namespace spinnaker -l "cluster=spin-deck" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace spinnaker $DECK_POD 9000 > /dev/null 2>&1 & echo $! > deck.pid

GATE_POD=$(kubectl get pods --namespace spinnaker -l "cluster=spin-gate" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace spinnaker $GATE_POD 8084 > /dev/null 2>&1 & echo $! > gate.pid

echo "Grafana default creds are admin / prom-operator"
